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

  double withXOffset(double offset) {
    return coordinateChart.withXOffset(offset);
  }

  double withXZoom(double offset) {
    return coordinateChart.withXZoom(offset);
  }

  double withYOffset(double offset) {
    return coordinateChart.withYOffset(offset);
  }

  void draw();
}
