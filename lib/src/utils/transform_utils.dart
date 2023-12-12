import 'package:flutter/widgets.dart';

/// @author jd
class TransformUtils {
  ///锚点
  final Offset anchor;
  final Size size;

  ///物理坐标系是从左上角开始，这里控制是否翻转，true就将逻辑坐标移到下面位置
  final bool reverseX;
  final bool reverseY;

  ///是否翻转两轴
  final bool reverseAxis;

  ///偏移
  final Offset offset;

  ///图形内边距，用于控制坐标轴的内边距
  final EdgeInsets padding;

  TransformUtils({
    required this.anchor,
    required this.size,
    required this.offset,
    required this.padding,
    this.reverseAxis = false,
    this.reverseX = false,
    this.reverseY = true,
  });

  ///将原点在左下角的逻辑坐标转换成物理坐标
  double transformX(double dx, {bool containPadding = true}) {
    double startAnchor = anchor.dx;
    double padRight = padding.right;
    double padLeft = padding.left;
    if (reverseAxis) {
      startAnchor = anchor.dy;
      padRight = padding.bottom;
      padLeft = -padding.right;
    }
    if (reverseX) {
      double x = startAnchor - dx;
      if (containPadding) {
        return x - padRight;
      }
      return x;
    }
    double x = startAnchor + dx;
    if (containPadding) {
      return x + padLeft;
    }
    return x;
  }

  ///将原点在左下角的逻辑坐标转换成物理坐标
  double transformY(double dy, {bool containPadding = true}) {
    double startAnchor = anchor.dy;
    double padRight = padding.bottom;
    double padLeft = padding.top;
    if (reverseAxis) {
      startAnchor = anchor.dx;
      padRight = -padding.left;
      padLeft = padding.left;
    }

    if (reverseY) {
      double y = startAnchor - dy;
      if (containPadding) {
        return y - padRight;
      }
      return y;
    } else {
      double y = startAnchor + dy;
      if (containPadding) {
        return y + padLeft;
      }
      return y;
    }
  }

  ///将逻辑坐标转换成物理坐标 xOffset/yOffset： 支持对应方向的滚动
  Offset transformOffset(Offset point, {bool containPadding = true, bool adjustDirection = false, bool xOffset = false, bool yOffset = false}) {
    double x = transformX(point.dx, containPadding: containPadding);
    double y = transformY(point.dy, containPadding: containPadding);
    if (adjustDirection && reverseAxis) {
      return Offset(withXOffset(y, yOffset), withYOffset(x, xOffset));
    }
    return Offset(withXOffset(x, xOffset), withYOffset(y, yOffset));
  }

  Rect transformRect(Rect rect, {bool containPadding = true}) {
    double x = transformX(offset.dx, containPadding: containPadding);
    double y = transformY(offset.dy, containPadding: containPadding);
    return Rect.fromLTWH(x, y, rect.width, rect.height);
  }

  Offset withOffset(Offset point, [bool scrollable = true]) {
    if (scrollable) {
      return Offset(point.dx - offset.dx, point.dy - offset.dy);
    }
    return point;
  }

  double withXOffset(double dx, [bool scrollable = true]) {
    if (scrollable) {
      return dx - offset.dx;
    }
    return dx;
  }

  //
  double withYOffset(double dy, [bool scrollable = true]) {
    if (scrollable) {
      if (reverseAxis) {
        return dy + offset.dy;
      }
      return dy - offset.dy;
    }
    return dy;
  }

  bool needAdjustFirst() {
    return reverseAxis ? padding.bottom == 0 : padding.left == 0;
  }

  bool needAdjustLast() {
    return reverseAxis ? padding.top == 0 : padding.right == 0;
  }
}
