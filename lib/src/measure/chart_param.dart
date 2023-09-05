import 'package:flutter/widgets.dart';

import '../measure/chart_layout_param.dart';

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

class ChartParam {
  ///图形外边距，用于控制坐标轴的外边距
  final EdgeInsets margin;

  ///图形内边距，用于控制坐标轴的内边距
  final EdgeInsets padding;

  ///点击的位置
  Offset? localPosition;

  ///缩放级别
  final double zoom;

  ///滚动偏移
  final Offset offset;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> childrenState = [];

  ChartParam({
    required this.margin,
    required this.padding,
    this.localPosition,
    this.zoom = 1,
    this.offset = Offset.zero,
    required this.childrenState,
  });

  @override
  bool operator ==(Object other) {
    if (other is ChartParam) {
      return super == other && zoom == other.zoom;
    }
    return super == other;
  }
}
