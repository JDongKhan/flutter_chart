import 'dart:ui';

import 'chart_coordinate_render.dart';

/// @author jd

abstract class ChartRender {
  ChartRender();
  //坐标系
  late ChartCoordinateRender coordinateChart;

  //初始化
  void init(ChartCoordinateRender coordinateChart) {
    this.coordinateChart = coordinateChart;
  }

  //自己做偏移粒度会更细
  double withXOffset(double offset, [bool scrollable = true]) {
    return coordinateChart.withXOffset(offset, scrollable);
  }

  double withXZoom(double offset) {
    return coordinateChart.withXZoom(offset);
  }

  //自己做偏移粒度会更细
  double withYOffset(double offset, [bool scrollable = true]) {
    return coordinateChart.withYOffset(offset, scrollable);
  }

  void draw(final Offset offset);
}
