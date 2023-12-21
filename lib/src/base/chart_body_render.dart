part of flutter_chart_plus;

/// @author jd

typedef ChartPosition<T> = num Function(T);

///图表主体
abstract class ChartBodyRender<T> extends _ChartRender {
  ///数据源
  final List<T> data;

  ///图表的布局状态
  late ChartLayoutState chartState;

  ///在图表中的位置
  late int index;

  ///跟哪个y轴关联
  final int yAxisPosition;

  ChartBodyRender({
    required this.data,
    this.yAxisPosition = 0,
  });

  late ChartController controller;

  //上一次的数据
  List<ChartItemLayoutState>? getLastData(bool need) {
    if (!need) {
      return null;
    }
    ChartBodyRender? e = controller.lastCoordinate?.charts[index];
    if (e == null) {
      return null;
    }
    return e.chartState.children;
  }

  List<num>? lerpList(List<num>? a, List<num>? b, double t) {
    if (b == null) {
      return null;
    }
    if (a == null || a.isEmpty) {
      return b.map((e) => ui.lerpDouble(null, e, t) as num).toList();
    }
    List<num> l = [];
    int index = 0;
    for (var element in b) {
      l.add(ui.lerpDouble(a[index], element, t) as num);
      index++;
    }
    return l;
  }
}
