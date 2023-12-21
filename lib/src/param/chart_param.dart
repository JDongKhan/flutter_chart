part of flutter_chart_plus;

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

abstract class ChartParam extends ChangeNotifier {
  ///布局信息
  final ChartLayoutInfo _layout = ChartLayoutInfo();
  ChartLayoutInfo get layout => _layout;

  set localPosition(v) {
    if (v != layout.localPosition) {
      layout.localPosition = v;
      notifyListeners();
    }
  }

  set zoom(v) {
    if (v != layout.zoom) {
      layout.zoom = v;
      notifyListeners();
    }
  }

  set offset(v) {
    if (v != layout.offset) {
      layout.offset = v;
      notifyListeners();
    }
  }

  ///不在屏幕内是否绘制 默认不绘制
  final bool outDraw;

  ///是否动画
  late bool animal;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> childrenState = [];

  ///获取所在位置的布局信息
  ChartLayoutParam paramAt(index) => childrenState[index];

  ChartParam({
    this.outDraw = false,
    double controlValue = 1,
    required this.childrenState,
  }) {
    _layout.controlValue = controlValue;
  }

  factory ChartParam.coordinate({
    bool outDraw = false,
    double controlValue = 1,
    required List<ChartLayoutParam> childrenState,
    required ChartCoordinateRender coordinate,
  }) {
    if (coordinate is ChartDimensionsCoordinateRender) {
      return _ChartDimensionParam.coordinate(
        outDraw: outDraw,
        childrenState: childrenState,
        coordinate: coordinate,
        controlValue: controlValue,
      )..animal = coordinate.animationDuration != null;
    }
    return _ChartCircularParam.coordinate(
      outDraw: outDraw,
      childrenState: childrenState,
      coordinate: coordinate as ChartCircularCoordinateRender,
      controlValue: controlValue,
    )..animal = coordinate.animationDuration != null;
  }

  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    _layout.size = size;
    _layout.margin = margin;
    _layout.padding = padding;
    _layout.content = margin + padding;
  }

  void scrollByDelta(Offset delta);

  void scroll(Offset offset);

  void scale(double zoom) {}

  @override
  bool operator ==(Object other) {
    if (other is ChartParam) {
      return super == other && _layout.zoom == other._layout.zoom && _layout.localPosition == other._layout.localPosition && _layout.offset == other._layout.offset;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _layout.zoom, _layout.offset, _layout.localPosition);

  ///刷新布局
  void setNeedsDraw() {
    notifyListeners();
  }
}

///坐标系布局信息
class ChartLayoutInfo {
  ///控制点
  double controlValue = 1;

  ///点击的位置
  Offset? localPosition;

  ///缩放级别
  double zoom = 1;

  ///滚动偏移
  Offset offset = Offset.zero;

  ///尺寸
  late Size size;

  ///外间隙
  late EdgeInsets margin;

  ///内间隙
  late EdgeInsets padding;

  ///坐标转换工具
  late TransformUtils transform;

  ///图形内容的外边距信息
  late EdgeInsets _content;
  set content(EdgeInsets v) {
    _content = v;
    left = v.left;
    right = size.width - v.right;
    top = v.top;
    bottom = size.height - v.bottom;
    contentWidth = size.width - v.horizontal;
    contentHeight = size.height - v.vertical;
  }

  EdgeInsets get content => _content;

  late double left;
  late double right;
  late double top;
  late double bottom;
  late double contentWidth;
  late double contentHeight;

  ChartLayoutInfo();

  double getPositionForX(double position, [bool withOffset = false]) {
    double xPos = position + left;
    if (withOffset) {
      xPos = transform.withXOffset(xPos);
    }
    return xPos;
  }

  double getPositionForY(double position) {
    double yPos = bottom - position;
    return yPos;
  }
}
