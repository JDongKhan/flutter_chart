//存放每条数据对应的绘图信息
import 'dart:math';
import 'dart:ui';

const double _maxWidth = 20;

//每个图形(点/柱状图/扇形)的状态
class ChartShapeState {
  Rect? rect;
  Path? path;
  ChartShapeState({
    this.rect,
    this.path,
  });
  //此处用链表来解决查找附近其他图形的逻辑
  //前面一个图形的信息 目的为了解决图形之间的关联信息
  ChartShapeState? preShapeState;
  //下一个图形的信息
  ChartShapeState? nextShapeState;
  //坐标系最左边
  double? left;
  //坐标系最右边
  double? right;
  //某条数据下 可能会有多条数据
  List<ChartShapeState> children = [];

  //矩形
  ChartShapeState.rect({required this.rect});

  //弧 用path保存 path不便于计算
  ChartShapeState.arc({
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

  //获取热区
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
      ChartShapeState next = nextShapeState!;
      bool reverse = nextShapeState!.rect!.center.dx < rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = next.rect!.right - rect!.left;
        if (diff > _maxWidth) {
          diff = _maxWidth;
        }
        l = rect!.left - diff / 2;
        r = rect!.right + _maxWidth;
      } else {
        double diff = next.rect!.left - rect!.right;
        if (diff > _maxWidth) {
          diff = _maxWidth;
        }
        l = rect!.left - _maxWidth;
        r = rect!.right + diff / 2;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    } else if (preShapeState != null && nextShapeState == null) {
      //说明是最后一个
      ChartShapeState pre = preShapeState!;
      bool reverse = preShapeState!.rect!.center.dx > rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = rect!.right - pre.rect!.left;
        if (diff > _maxWidth) {
          diff = _maxWidth;
        }
        l = rect!.left - _maxWidth;
        r = rect!.right + diff / 2;
      } else {
        double diff = rect!.left - pre.rect!.right;
        if (diff > _maxWidth) {
          diff = _maxWidth;
        }
        l = rect!.left - diff / 2;
        r = rect!.right + _maxWidth;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    } else if (preShapeState != null && nextShapeState != null) {
      //说明是中间点
      ChartShapeState next = nextShapeState!;
      ChartShapeState pre = preShapeState!;
      bool reverse = nextShapeState!.rect!.center.dx < rect!.center.dx;
      double l = rect!.left;
      double r = rect!.right;
      //说明是逆序
      if (reverse) {
        reverse = true;
        double diff = rect!.right - pre.rect!.left;
        if (diff > _maxWidth) {
          diff = _maxWidth;
        }
        l = left!;
        r = rect!.right + diff / 2;
      } else {
        double diffLeft = rect!.left - pre.rect!.right;
        double diffRight = next.rect!.left - rect!.right;
        if (diffLeft > _maxWidth) {
          diffLeft = _maxWidth;
        }
        if (diffRight > _maxWidth) {
          diffRight = _maxWidth;
        }
        l = rect!.left - diffLeft / 2;
        r = rect!.right + diffRight / 2;
      }
      return Rect.fromLTRB(l, rect!.top, r, rect!.bottom);
    }
    return null;
  }

  //判断热区是否命中
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
}
