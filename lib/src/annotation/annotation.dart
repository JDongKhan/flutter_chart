import '../../flutter_chart.dart';

abstract class Annotation<T> extends ChartRender<T> {
  final bool scroll;
  Annotation({
    this.scroll = false,
  });
}
