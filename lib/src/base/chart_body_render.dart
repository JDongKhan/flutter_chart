import 'chart_render.dart';
import '../measure/chart_shape_layout_param.dart';

/// @author jd

typedef ChartPosition<T> = num Function(T);

///图表主体
abstract class ChartBodyRender<T> extends ChartRender {
  ///数据源
  final List<T> data;

  ///图表的布局状态
  late ChartShapeLayoutParam layoutParam;

  ///跟哪个y轴关联
  final int yAxisPosition;
  ChartBodyRender({
    required this.data,
    this.yAxisPosition = 0,
  });
}
