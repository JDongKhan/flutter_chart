import 'package:flutter/material.dart';

import '../measure/chart_param.dart';
import '../coordinate/chart_coordinate_render.dart';
import '../coordinate/chart_dimensions_coordinate_render.dart';
import 'annotation.dart';

/// @author jd
//区间标注
class RegionAnnotation extends Annotation {
  ///区间在x轴上的位置，两个长度
  final List<num> positions;

  ///区间颜色
  final Color color;

  RegionAnnotation({
    super.scroll = true,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.positions,
    this.color = const Color(0xFFF5F5F5),
  });

  Paint? _paint;
  @override
  void init(ChartCoordinateRender coordinateChart) {
    super.init(coordinateChart);
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
  }

  @override
  void draw(ChartParam param, Canvas canvas, Size size) {
    if (!needDraw(param)) {
      return;
    }
    if (coordinateChart is ChartDimensionsCoordinateRender) {
      ChartDimensionsCoordinateRender chart = coordinateChart as ChartDimensionsCoordinateRender;
      assert(positions.length == 2, 'positions must be two length');
      num po1 = positions[0];
      num po2 = positions[1];
      double start = chart.transformUtils.transformX(po1 * chart.xAxis.density);
      start = chart.transformUtils.withXZoomOffset(start);
      double end = chart.transformUtils.transformX(po2 * chart.xAxis.density);
      end = chart.transformUtils.withXZoomOffset(end);

      double top = chart.contentMargin.top;
      double bottom = chart.size.height - chart.contentMargin.bottom;
      if (_paint != null) {
        canvas.drawRect(Rect.fromLTRB(start, top, end, bottom), _paint!);
      }
    }
  }
}
