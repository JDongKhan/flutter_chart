import 'package:flutter/widgets.dart';

class TransformUtils {
  ///锚点
  final Offset anchor;
  final Size size;
  //物理坐标系是从左上角开始，这里控制是否翻转，true就将逻辑坐标移到下面位置
  final bool reverseX;
  final bool reverseY;
  //偏移
  final Offset offset;
  //图形内边距，用于控制坐标轴的内边距
  final EdgeInsets padding;
  final bool zoomHorizontal;
  final bool zoomVertical;
  final double zoom;

  TransformUtils({
    required this.anchor,
    required this.size,
    required this.offset,
    required this.zoom,
    required this.padding,
    required this.zoomVertical,
    required this.zoomHorizontal,
    this.reverseX = false,
    this.reverseY = true,
  });

  //将原点在左下角的逻辑坐标转换成物理坐标
  double transformX(double dx, {bool containPadding = true}) {
    if (reverseX) {
      double x = anchor.dx - dx;
      if (containPadding) {
        return x - padding.right;
      }
      return x;
    }
    double x = anchor.dx + dx;
    if (containPadding) {
      return x + padding.left;
    }
    return x;
  }

  //将原点在左下角的逻辑坐标转换成物理坐标
  double transformY(double dy, {bool containPadding = true}) {
    if (reverseY) {
      double y = anchor.dy - dy;
      if (containPadding) {
        return y - padding.bottom;
      }
      return y;
    } else {
      double y = anchor.dy + dy;
      if (containPadding) {
        return y + padding.top;
      }
      return y;
    }
  }

  //将逻辑坐标转换成物理坐标
  Offset transformOffset(Offset offset, {bool containPadding = true}) {
    double x = transformX(offset.dx, containPadding: containPadding);
    double y = transformY(offset.dy, containPadding: containPadding);
    return Offset(x, y);
  }

  Rect transformRect(Rect rect, {bool containPadding = true}) {
    double x = transformX(offset.dx, containPadding: containPadding);
    double y = transformY(offset.dy, containPadding: containPadding);
    return Rect.fromLTWH(x, y, rect.width, rect.height);
  }

  //缩放后的偏移
  Offset get zoomOffset {
    double x = offset.dx;
    double y = offset.dy;
    if (zoomHorizontal) {
      x = offset.dx * zoom;
    }
    if (zoomVertical) {
      y = offset.dy;
    }
    return Offset(x, y);
  }

  Offset withZoomOffset(Offset point, [bool scrollable = true]) {
    if (scrollable) {
      return Offset(point.dx - zoomOffset.dx, point.dy - zoomOffset.dy);
    }
    return point;
  }

  double withXZoomOffset(double dx, [bool scrollable = true]) {
    if (scrollable) {
      return dx - zoomOffset.dx;
    }
    return dx;
  }

  //
  double withYOffset(double dy, [bool scrollable = true]) {
    if (scrollable) {
      return dy - zoomOffset.dy;
    }
    return dy;
  }
}
