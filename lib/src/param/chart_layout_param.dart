part of flutter_chart_plus;

/// @author jd
const double _maxWidth = 15;

///每个图形(点/柱状图/扇形)的状态
class ChartLayoutParam {
  ///图形的区域
  Rect? originRect;

  ///形成图形的path
  Path? path;

  ChartLayoutParam();

  ///数据所在数组的位置
  int? index;

  //选中children的索引
  int? selectedIndex;

  ///此处用链表来解决查找附近其他图形的逻辑
  ///前面一个图形的信息 目的为了解决图形之间的关联信息
  ChartLayoutParam? preShapeState;

  ///下一个图形的信息
  ChartLayoutParam? nextShapeState;

  ///坐标系最左边
  double? left;

  ///坐标系最右边
  double? right;

  ///对应数据x轴的原始值
  num? xValue;

  ///对应数据y轴的原始值
  num? yValue;

  int yAxisPosition = 0;

  ///对应数据y轴的原始值
  List<num>? yValues;

  ///布局信息
  ChartLayoutInfo? layout;

  ///某条数据下 可能会有多条数据
  List<ChartLayoutParam> children = [];

  ///矩形
  ChartLayoutParam.rect({required this.originRect});

  ///路径
  ChartLayoutParam.path({required this.path});

  ///弧 用path保存 path不便于计算
  ChartLayoutParam.arc({
    required Offset center, // 中心点
    required double innerRadius, // 小圆半径
    required double outRadius, // 大圆半径
    required double startAngle,
    required double sweepAngle,
  }) {
    originRect = null;
    double startRad = startAngle;
    double endRad = startAngle + sweepAngle;

    double r0 = innerRadius;
    double r1 = outRadius;
    Offset p0 = Offset(math.cos(startRad) * r0, math.sin(startRad) * r0);
    Offset p1 = Offset(math.cos(startRad) * r1, math.sin(startRad) * r1);
    Offset q0 = Offset(math.cos(endRad) * r0, math.sin(endRad) * r0);
    Offset q1 = Offset(math.cos(endRad) * r1, math.sin(endRad) * r1);

    bool large = sweepAngle.abs() > math.pi;
    bool clockwise = sweepAngle > 0;

    Path localPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..arcToPoint(q1, radius: Radius.circular(r1), clockwise: clockwise, largeArc: large)
      ..lineTo(q0.dx, q0.dy)
      ..arcToPoint(p0, radius: Radius.circular(r0), clockwise: !clockwise, largeArc: large);
    path = localPath.shift(center);
  }

  void setOriginRect(Rect rect) {
    originRect = rect;
  }

  Rect? getRealRect() {
    ChartLayoutInfo? layout = this.layout;
    if (layout == null) {
      return originRect;
    }
    if (this is ChartLineLayoutParam) {
      double left = layout.contentMargin.left;
      double top = layout.contentMargin.top;
      double bottom = layout.size.height - layout.contentMargin.bottom;
      ChartLineLayoutParam p = this as ChartLineLayoutParam;
      double dotRadius = originRect!.width / 2;
      double xPos = xValue! * p.xAxis.density + left;
      xPos = layout.transform.withXOffset(xPos);
      if (yValue != null) {
        double yPos = bottom - p.yAxis[yAxisPosition].relativeHeight(yValue!);
        Offset currentPoint = Offset(xPos, yPos);
        return Rect.fromCenter(center: currentPoint, width: dotRadius, height: dotRadius);
      } else {
        return Rect.fromLTRB(xPos - dotRadius, top, xPos + dotRadius, bottom);
      }
    }
    return originRect;
  }

  ///获取热区
  Rect? getHotRect() {
    Rect? currentRect = getRealRect();
    if (currentRect == null) {
      return Rect.zero;
    }
    Rect? preRect = preShapeState?.getRealRect();
    Rect? nextRect = nextShapeState?.getRealRect();

    double l = currentRect.left;
    double r = currentRect.right;
    double t = currentRect.top;
    double b = currentRect.bottom;
    //处理前后关联热区
    if (preRect == null && nextRect == null) {
      //都为空有两种情况
      //1、数据只有一条
      //2、该图不需要处理热区
      if (left != null && right != null) {
        //说明是第一种情况
        return Rect.fromLTRB(l - _maxWidth, t, r + _maxWidth, b);
      }
      return null;
    } else if (preRect == null && nextRect != null) {
      //说明是第一个
      double diff = nextRect.left - r;
      if (diff > _maxWidth * 2) {
        diff = _maxWidth * 2;
      }
      return Rect.fromLTRB(l - _maxWidth, t, r + diff / 2, b);
    } else if (preRect != null && nextRect == null) {
      //说明是最后一个
      double diff = l - preRect.right;
      if (diff > _maxWidth * 2) {
        diff = _maxWidth * 2;
      }
      return Rect.fromLTRB(l - diff / 2, t, r + _maxWidth, b);
    } else if (preRect != null && nextRect != null) {
      //说明是中间点
      double diffLeft = l - preRect.right;
      double diffRight = nextRect.left - r;
      if (diffLeft > _maxWidth * 2) {
        diffLeft = _maxWidth * 2;
      }
      if (diffRight > _maxWidth * 2) {
        diffRight = _maxWidth * 2;
      }
      return Rect.fromLTRB(l - diffLeft / 2, t, r + diffRight / 2, b);
    }
    return null;
  }

  ///判断热区是否命中
  bool hitTest(Offset? anchor) {
    if (anchor == null) {
      return false;
    }

    if (originRect?.contains(anchor) == true) {
      return true;
    }

    if (path?.contains(anchor) == true) {
      return true;
    }

    Rect? hotRect = getHotRect();
    if (hotRect?.contains(anchor) == true) {
      return true;
    }

    return false;
  }

  @override
  String toString() {
    return '{index:$index xValue:$xValue,yValue:$yValue}';
  }
}

class ChartLineLayoutParam extends ChartLayoutParam {
  ///y坐标轴
  late List<YAxis> yAxis;

  ///x坐标轴
  late XAxis xAxis;
}
