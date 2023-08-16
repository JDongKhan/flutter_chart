import 'dart:ui';

import '../coordinate/chart_coordinate_render.dart';

/// @author jd

///图表里的渲染器父类，直接子类包括ChartBodyRender和Annotation
abstract class ChartRender {
  ChartRender();

  ///坐标系
  late ChartCoordinateRender coordinateChart;

  ///初始化
  void init(ChartCoordinateRender coordinateChart) {
    this.coordinateChart = coordinateChart;
  }

  void draw(Canvas canvas, Size size);
}
