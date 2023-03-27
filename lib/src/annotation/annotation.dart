import '../base/chart_render.dart';

abstract class Annotation extends ChartRender {
  final bool scroll;
  final int yAxisPosition;
  Annotation({
    this.scroll = false,
    this.yAxisPosition = 0,
  });
}
