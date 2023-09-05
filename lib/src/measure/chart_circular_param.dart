import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_chart_plus/src/measure/chart_param.dart';

import '../coordinate/chart_circular_coordinate_render.dart';
import '../utils/transform_utils.dart';

class ChartCircularParam extends ChartParam {
  ///半径
  late double radius;

  ///中心点
  late Offset center;

  final double borderWidth;

  final ArcPosition arcPosition;

  ChartCircularParam.coordinate({
    super.localPosition,
    super.zoom = 1,
    super.offset = Offset.zero,
    required super.childrenState,
    required ChartCircularCoordinateRender coordinate,
  })  : arcPosition = coordinate.arcPosition,
        borderWidth = coordinate.borderWidth;

  @override
  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    super.init(size: size, margin: margin, padding: padding);
    final sw = size.width - contentMargin.horizontal;
    final sh = size.height - contentMargin.vertical;
    //满圆
    if (arcPosition == ArcPosition.none) {
      // 确定圆的半径
      radius = math.min(sw, sh) / 2 - borderWidth / 2;
      // 定义中心点
      center = size.center(Offset.zero);
      transformUtils = TransformUtils(
        anchor: center,
        size: size,
        padding: padding,
        zoomVertical: false,
        zoomHorizontal: false,
        zoom: zoom,
        offset: offset,
        reverseX: false,
        reverseY: false,
      );
    } else {
      //带有弧度
      double maxSize = math.max(sw, sh);
      double minSize = math.min(sw, sh);
      radius = math.min(maxSize / 2, minSize) - borderWidth / 2;
      center = size.center(Offset.zero);
      double startAngle = 0;
      double sweepAngle = math.pi;
      if (arcPosition == ArcPosition.up) {
        startAngle = math.pi;
        center = Offset(center.dx, size.height - contentMargin.bottom);
        transformUtils = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          zoomVertical: false,
          zoomHorizontal: false,
          zoom: zoom,
          offset: offset,
          reverseX: false,
          reverseY: true,
        );
      } else if (arcPosition == ArcPosition.down) {
        center = Offset(center.dx, contentMargin.top);
        transformUtils = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          zoomVertical: false,
          zoomHorizontal: false,
          zoom: zoom,
          offset: offset,
          reverseX: false,
          reverseY: false,
        );
      }
    }
  }

  void scroll(Offset offset) {}
}
