part of flutter_chart_plus;

/// @author jd

///图表里的渲染器父类，直接子类包括ChartBodyRender和Annotation
abstract class _ChartRender {
  _ChartRender();

  bool isInit = false;

  ///初始化  耗时的方法都可以放到这里
  void init(ChartsParam param) {
    isInit = true;
  }

  void draw(Canvas canvas, ChartsParam param);
}
