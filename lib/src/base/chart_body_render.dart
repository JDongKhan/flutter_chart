import 'chart_render.dart';
import 'chart_shape_state.dart';

/// @author jd

typedef ChartPosition<T> = num Function(T);

///图表主体
abstract class ChartBodyRender<T> extends ChartRender {
  ///数据源
  final List<T> data;

  ///图表的状态
  late CharBodyState bodyState;

  ///跟哪个y轴关联
  final int yAxisPosition;
  ChartBodyRender({
    required this.data,
    this.yAxisPosition = 0,
  });
}
