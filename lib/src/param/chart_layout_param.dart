//存放每条数据对应的绘图信息
import 'dart:math';
import 'dart:ui';

/// @author jd
const double _maxWidth = 15;

@Deprecated('instead of  using [ChartLayoutParam]')
typedef CharBodyState = ChartLayoutParam;

///每个图形(点/柱状图/扇形)的状态
class ChartLayoutParam {
  ///图形的区域
  Rect? rect;

  ///形成图形的path
  Path? path;

  ChartLayoutParam({
    this.rect,
    this.path,
  });

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

  ///对应数据y轴的原始值
  List<num>? yValues;

  ///某条数据下 可能会有多条数据
  List<ChartLayoutParam> children = [];

  ///矩形
  ChartLayoutParam.rect({required this.rect});

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
    rect = null;
    double startRad = startAngle;
    double endRad = startAngle + sweepAngle;

    double r0 = innerRadius;
    double r1 = outRadius;
    Offset p0 = Offset(cos(startRad) * r0, sin(startRad) * r0);
    Offset p1 = Offset(cos(startRad) * r1, sin(startRad) * r1);
    Offset q0 = Offset(cos(endRad) * r0, sin(endRad) * r0);
    Offset q1 = Offset(cos(endRad) * r1, sin(endRad) * r1);

    bool large = sweepAngle.abs() > pi;
    bool clockwise = sweepAngle > 0;

    Path localPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..arcToPoint(q1, radius: Radius.circular(r1), clockwise: clockwise, largeArc: large)
      ..lineTo(q0.dx, q0.dy)
      ..arcToPoint(p0, radius: Radius.circular(r0), clockwise: !clockwise, largeArc: large);
    path = localPath.shift(center);
  }

  void setRect(Rect rect) {
    this.rect = rect;
  }

  ///获取热区
  Rect? getHotRect() {
    //处理前后关联热区
    if (preShapeState == null && nextShapeState == null) {
      //都为空有两种情况
      //1、数据只有一条
      //2、该图不需要处理热区
      if (left != null && right != null) {
        //说明是第一种情况
        return Rect.fromLTRB(rect!.left - _maxWidth, rect!.top, rect!.right + _maxWidth, rect!.bottom);
      }
      return null;
    } else if (preShapeState == null && nextShapeState != null) {
      //说明是第一个
      ChartLayoutParam next = nextShapeState!;
      bool reverse = nextShapeState!.rect!.center.dx < rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = next.rect!.right - rect!.left;
        if (diff > _maxWidth * 2) {
          diff = _maxWidth * 2;
        }
        l = rect!.left - diff / 2;
        r = rect!.right + _maxWidth;
      } else {
        double diff = next.rect!.left - rect!.right;
        if (diff > _maxWidth * 2) {
          diff = _maxWidth * 2;
        }
        l = rect!.left - _maxWidth;
        r = rect!.right + diff / 2;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    } else if (preShapeState != null && nextShapeState == null) {
      //说明是最后一个
      ChartLayoutParam pre = preShapeState!;
      bool reverse = preShapeState!.rect!.center.dx > rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = rect!.right - pre.rect!.left;
        if (diff > _maxWidth * 2) {
          diff = _maxWidth * 2;
        }
        l = rect!.left - _maxWidth;
        r = rect!.right + diff / 2;
      } else {
        double diff = rect!.left - pre.rect!.right;
        if (diff > _maxWidth * 2) {
          diff = _maxWidth * 2;
        }
        l = rect!.left - diff / 2;
        r = rect!.right + _maxWidth;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    } else if (preShapeState != null && nextShapeState != null) {
      //说明是中间点
      ChartLayoutParam next = nextShapeState!;
      ChartLayoutParam pre = preShapeState!;
      bool reverse = nextShapeState!.rect!.center.dx < rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = rect!.right - pre.rect!.left;
        if (diff > _maxWidth * 2) {
          diff = _maxWidth * 2;
        }
        l = left!;
        r = rect!.right + diff / 2;
      } else {
        double diffLeft = rect!.left - pre.rect!.right;
        double diffRight = next.rect!.left - rect!.right;
        if (diffLeft > _maxWidth * 2) {
          diffLeft = _maxWidth * 2;
        }
        if (diffRight > _maxWidth * 2) {
          diffRight = _maxWidth * 2;
        }
        l = rect!.left - diffLeft / 2;
        r = rect!.right + diffRight / 2;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    }
    return null;
  }

  ///判断热区是否命中
  bool hitTest(Offset? anchor) {
    if (anchor == null) {
      return false;
    }

    if (rect?.contains(anchor) == true) {
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
