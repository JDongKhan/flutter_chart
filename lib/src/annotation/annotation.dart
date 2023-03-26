import '../base/chart_render.dart';

abstract class Annotation<T> extends ChartRender<T> {
  final bool scroll;
  Annotation({
    this.scroll = false,
  });
}
