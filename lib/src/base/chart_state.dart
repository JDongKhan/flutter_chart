import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

//数据共享，便于各个节点使用
class ChartState extends ChangeNotifier {
  Offset? _gesturePoint;
  set gesturePoint(value) {
    if (value != _gesturePoint) {
      _gesturePoint = value;
      notifyListeners();
    }
  }

  Offset? get gesturePoint => _gesturePoint;

  double _zoom = 1;
  //缩放
  double get zoom => _zoom;
  set zoom(v) {
    gesturePoint = null;
    _zoom = v;
  }

  //偏移
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(v) {
    gesturePoint = null;
    _offset = v;
  }

  //根据位置缓存配置信息
  Map<int, CharBodyState> bodyStateList = {};
}

class CharBodyState {
  int? selectedIndex;
  List<ChartShapeState>? shapeList;
}

//存放每条数据对应的绘图信息
class ChartShapeState {
  Rect? rect;
  //热区 用于逻辑处理 比如line下，要计算前面和后面的位置信息才能决定自己的热区
  Rect? hotRect;
  //用于判断是否命中
  Path? hotPath;
  Path? path;
  ChartShapeState({
    this.rect,
    this.path,
  });
  //某条数据下 可能会有多条数据
  List<ChartShapeState> children = [];

  ChartShapeState.rect({
    required this.rect,
    Rect? hotRect,
  })  : hotRect = hotRect ?? Rect.fromLTRB(rect!.left, rect.top, rect.right, rect.bottom),
        path = Path()..addRect(rect!),
        hotPath = Path()..addRect(hotRect ?? Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom));

  ChartShapeState.oval({
    required this.rect,
    Rect? hotRect,
  })  : hotRect = hotRect ?? Rect.fromLTRB(rect!.left, rect.top, rect.right, rect.bottom),
        path = Path()..addOval(rect!),
        hotPath = Path()..addOval(hotRect ?? Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom));

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
    //扇形热区和画的一样，不用特别处理
    hotPath = path;
  }

  void translateHotRect({double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    if (hotRect == null) {
      return;
    }
    hotRect = Rect.fromLTRB(hotRect!.left + left, hotRect!.top + top, hotRect!.right + right, hotRect!.bottom + bottom);
    hotPath = Path()..addRect(hotRect!);
  }

  //判断热区是否命中
  bool hitTest(Offset? anchor) {
    if (anchor == null) {
      return false;
    }
    if (hotPath?.contains(anchor) == true) {
      return true;
    }
    return false;
  }
}
