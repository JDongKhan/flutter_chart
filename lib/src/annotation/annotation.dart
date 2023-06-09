import 'package:flutter/foundation.dart';

import '../base/chart_render.dart';

abstract class Annotation extends ChartRender {
  final bool scroll;
  //跟哪个y轴关联
  final int yAxisPosition;
  //携带额外信息
  final dynamic userInfo;
  final double? minZoomVisible;
  final double? maxZoomVisible;
  //标注可以点击
  final ValueChanged<Annotation>? onTap;
  Annotation({
    this.scroll = false,
    this.yAxisPosition = 0,
    this.userInfo,
    this.onTap,
    this.minZoomVisible,
    this.maxZoomVisible,
  });
}
