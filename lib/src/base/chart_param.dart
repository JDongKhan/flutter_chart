import 'package:flutter/widgets.dart';

import '../measure/chart_layout_param.dart';

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

class ChartParam {
  ///点击的位置
  Offset? localPosition;

  ///缩放级别
  double zoom = 1;

  ///滚动偏移
  Offset offset = Offset.zero;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> childrenState = [];

  ChartParam({
    this.localPosition,
    required this.zoom,
    required this.offset,
    required this.childrenState,
  });

  void reset() {
    zoom = 1.0;
    offset = Offset.zero;
    // resetTooltip();
  }

  @override
  bool operator ==(Object other) {
    if (other is ChartParam) {
      return super == other && zoom == other.zoom;
    }
    return super == other;
  }
}
