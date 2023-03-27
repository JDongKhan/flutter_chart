import 'package:flutter_chart/src/base/chart_render.dart';

import '../../flutter_chart.dart';

/// @author jd

typedef ChartPosition<T> = num Function(T);

abstract class ChartBodyRender<T> extends ChartRender {
  final List<T> data;
  late CharBodyState bodyState;
  //在图表中的顺序
  late int positionIndex;
  //数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ChartBodyRender({
    required this.data,
    required this.position,
  });
}
