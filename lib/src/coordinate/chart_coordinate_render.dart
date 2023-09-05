import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/src/base/chart_controller.dart';

import '../annotation/annotation.dart';
import '../base/chart_param.dart';
import '../measure/chart_layout_param.dart';
import '../utils/transform_utils.dart';
import '../widget/chart_widget.dart';
import '../base/chart_body_render.dart';

///
/// @author JD

///十字准星样式
class CrossHairStyle {
  final Color color;
  final bool horizontalShow;
  final bool verticalShow;
  final double strokeWidth;
  //自动调整水平方向位置
  final bool adjustHorizontal;
  //自动调整垂直方向位置
  final bool adjustVertical;
  const CrossHairStyle({
    this.color = Colors.blue,
    this.horizontalShow = true,
    this.verticalShow = true,
    this.strokeWidth = 0.5,
    this.adjustHorizontal = false,
    this.adjustVertical = false,
  });
}

typedef ChartTooltipFormatter = InlineSpan? Function(List<ChartLayoutParam>);

///坐标渲染器， 每次刷新会重新构造，切忌不要存放状态数据，数据都在state里面
abstract class ChartCoordinateRender {
  ///图形外边距，用于控制坐标轴的外边距
  final EdgeInsets margin;

  ///图形内边距，用于控制坐标轴的内边距
  final EdgeInsets padding;

  ///缩放比例
  final bool zoomHorizontal;
  final bool zoomVertical;

  ///最小缩放
  final double? minZoom;

  ///最大缩放
  final double? maxZoom;

  ///坐标系中间的绘图
  final List<ChartBodyRender> charts;

  ///安全区域
  final EdgeInsets? safeArea;

  ///用widget弹框来处理点击
  final TooltipWidgetBuilder? tooltipBuilder;

  ///背景标注
  final List<Annotation>? backgroundAnnotations;

  ///前景标注
  final List<Annotation>? foregroundAnnotations;

  ChartCoordinateRender({
    required this.margin,
    required this.padding,
    required this.charts,
    this.tooltipBuilder,
    this.zoomHorizontal = false,
    this.zoomVertical = false,
    this.minZoom,
    this.maxZoom,
    this.backgroundAnnotations,
    this.foregroundAnnotations,
    this.safeArea,
  }) : contentMargin = EdgeInsets.fromLTRB(margin.left + padding.left, margin.top + padding.top, margin.right + padding.right, margin.bottom + padding.bottom);

  ///坐标转换工具
  late TransformUtils transformUtils;

  late ChartController controller;

  ///画布尺寸
  late Size size;

  ///图形内容的外边距信息
  EdgeInsets contentMargin;

  ///未处理的坐标  原点在左上角
  Rect get contentRect => Rect.fromLTRB(contentMargin.left, contentMargin.top, size.width - contentMargin.left, size.height - contentMargin.bottom);

  void init(Size size) {
    this.size = size;
    for (var element in charts) {
      element.init(this);
    }
  }

  void paint(ChartParam param, Canvas canvas, Size size);
}
