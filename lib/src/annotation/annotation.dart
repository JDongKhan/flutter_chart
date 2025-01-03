part of flutter_chart_plus;

/// @author jd
abstract class Annotation extends _ChartRender {

  Annotation({
    this.fixed = false,
    this.yAxisPosition = 0,
    this.userInfo,
    this.onTap,
    this.minZoomVisible,
    this.maxZoomVisible,
  });

  ///是否滚动
  final bool fixed;

  ///跟哪个y轴关联
  final int yAxisPosition;

  ///携带额外信息
  final dynamic userInfo;

  ///小于该缩放级别则隐藏
  final double? minZoomVisible;

  ///大于该缩放级别则隐藏
  final double? maxZoomVisible;

  ///标注可以点击
  final ValueChanged<Annotation>? onTap;

  ///所在的区域
  Rect? rect;


  ///判断point是否在此Annotation范围内
  bool isRange(Offset point) {
    if (rect == null) {
      return false;
    }
    return rect!.contains(point);
  }

  ///是否需要绘制
  bool isNeedDraw(ChartsState state) {
    if (minZoomVisible != null && state.layout.zoom < minZoomVisible!) {
      return false;
    }
    if (maxZoomVisible != null && state.layout.zoom > maxZoomVisible!) {
      return false;
    }
    return true;
  }
}
