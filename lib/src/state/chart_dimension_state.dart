part of flutter_chart_plus;

///象限坐标系信息
class ChartDimensionCoordinateState extends ChartCoordinateState {

  ChartDimensionCoordinateState({
    required super.size,
    required super.margin,
    required super.padding,
    required super.controlValue,
    required this.yAxis,
    required this.xAxis,
    required this.invert,
  });

  ///y坐标轴
  final List<YAxis> yAxis;

  ///x坐标轴
  final XAxis xAxis;

  ///是否反转
  final bool invert;


  @override
  void init() {
    //初始化配置
    double width = size.width;
    double height = size.height;
    int count = xAxis.count;
    assert(xAxis.count > 0, "x轴数量必须大于0");
    assert(xAxis.interval > 0, "x轴数量必须大于0");
    //每格的宽度，用于控制一屏最多显示个数
    double density = invert ? (height - content.vertical) / count / xAxis.interval : (width - content.horizontal) / count / xAxis.interval;
    xAxis.fixedDensity = density;
    //x轴密度 即1 value 等于多少尺寸
    if (xAxis.zoom) {
      xAxis.density = density * zoom;
    } else {
      xAxis.density = density;
    }

    for (YAxis yA in yAxis) {
      num max = yA.max;
      num min = yA.min;
      int yCount = yA.count;
      //y轴密度  即1 value 等于多少尺寸
      double itemHeight = invert ? (width - margin.horizontal) / yCount : (height - margin.vertical) / yCount;
      double itemValue = (max - min) / yCount;
      double density = itemHeight / itemValue;
      yA.fixedDensity = density;
      if (yA.zoom) {
        yA.density = density * zoom;
      } else {
        yA.density = density;
      }
    }

    //转换工具
    transform = TransformUtils(
      anchor: Offset(margin.left, size.height - margin.bottom),
      offset: offset,
      size: size,
      padding: padding,
      reverseX: invert ? true : false,
      reverseY: invert ? false : true,
      reverseAxis: invert,
    );
  }
}

class _ChartDimensionState extends ChartsState {
  _ChartDimensionState.coordinate({
    required Size size,
    required EdgeInsets margin,
    required EdgeInsets padding,
    super.outDraw,
    required super.chartsState,
    required ChartDimensionsCoordinateRender coordinate,
    double controlValue = 1,
  }) {
    super._layout = ChartDimensionCoordinateState(
      size: size,
      margin: margin,
      padding: padding,
      controlValue: controlValue,
      yAxis: coordinate.yAxis,
      xAxis: coordinate.xAxis,
      invert: coordinate is ChartInvertDimensionsCoordinateRender,
    );
  }

  @override
  void init() {
    super.layout.init();
  }

  @override
  void scrollByDelta(Offset delta) {
    ChartDimensionCoordinateState layout = super.layout as ChartDimensionCoordinateState;
    Offset newOffset = layout.offset.translate(-delta.dx, layout.invert ? delta.dy : -delta.dy);
    scroll(newOffset);
  }

  @override
  void scroll(Offset offset) {
    ChartDimensionCoordinateState layout = super.layout as ChartDimensionCoordinateState;
    //校准偏移，不然缩小后可能起点都在中间了，或者无限滚动
    double x = offset.dx;
    // double y = newOffset.dy;
    if (x < 0) {
      x = 0;
    }
    //放大的场景  offset会受到zoom的影响，所以这里的宽度要先剔除zoom的影响再比较
    double chartContentWidth = layout.xAxis.density * layout.xAxis.max;
    double chartViewPortWidth = layout.size.width - layout.content.horizontal;
    //处理成跟缩放无关的偏移
    double maxOffset = (chartContentWidth - chartViewPortWidth);
    if (maxOffset < 0) {
      //内容小于0
      x = 0;
    } else if (x > maxOffset) {
      x = maxOffset;
    }

    //y变化
    double y = 0;
    if (layout.invert) {
      y = offset.dy;
      if (y < 0) {
        y = 0;
      }
      //放大的场景  offset会受到zoom的影响，所以这里的宽度要先剔除zoom的影响再比较
      double chartContentWidth = layout.xAxis.density * layout.xAxis.max;
      double chartViewPortWidth = layout.size.height - layout.content.vertical;
      //处理成跟缩放无关的偏移
      double maxOffset = (chartContentWidth - chartViewPortWidth);
      if (maxOffset < 0) {
        //内容小于0
        y = 0;
      } else if (y > maxOffset) {
        y = maxOffset;
      }
    }
    this.offset = Offset(x, y);
  }
}
