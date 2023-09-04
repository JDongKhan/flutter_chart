import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';
import 'chart_param.dart';

/// @author jd

///数据共享，便于各个节点使用
class ChartController {
  ///
  late ChartCoordinateRender chartCoordinateRender;

  ///chart 图形参数
  late ChartParam param;

  ///使用widget渲染tooltip
  void showTooltipBuilder({required AnnotationTooltipWidgetBuilder builder, required Offset position}) {
    param.tooltipWidgetBuilder = builder;
    param.localPosition = position;
    param.notifyTooltip();
  }

  void scrollByDelta(Offset delta) {
    Offset newOffset = param.offset.translate(-delta.dx, -delta.dy);
    scroll(newOffset);
  }

  void scroll(Offset offset) {
    //校准偏移，不然缩小后可能起点都在中间了，或者无限滚动
    double x = offset.dx;
    // double y = newOffset.dy;
    if (x < 0) {
      x = 0;
    }
    if (chartCoordinateRender is DimensionsChartCoordinateRender) {
      DimensionsChartCoordinateRender render = chartCoordinateRender as DimensionsChartCoordinateRender;
      //放大的场景  offset会受到zoom的影响，所以这里的宽度要先剔除zoom的影响再比较
      double chartContentWidth = render.xAxis.density * (render.xAxis.max ?? render.xAxis.count);
      double chartViewPortWidth = render.size.width - render.contentMargin.horizontal;
      //处理成跟缩放无关的偏移
      double maxOffset = (chartContentWidth - chartViewPortWidth);
      if (maxOffset < 0) {
        //内容小于0
        x = 0;
      } else if (x > maxOffset) {
        x = maxOffset;
      }
    }
    param.offset = Offset(x, 0);
  }
}
