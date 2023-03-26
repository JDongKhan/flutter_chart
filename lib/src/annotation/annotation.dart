import '../base/chart_render.dart';

abstract class Annotation extends ChartRender {
  final bool scroll;
  Annotation({
    this.scroll = false,
  });
}
