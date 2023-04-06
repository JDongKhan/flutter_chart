import 'package:flutter/material.dart';

import '../annotation/annotation.dart';
import '../utils/transform_utils.dart';
import '../widget/chart_widget.dart';
import 'chart_body_render.dart';
import 'chart_controller.dart';

///
/// @author JD

const List<Color> colors10 = [
  Color(0xff5b8ff9),
  Color(0xff5ad8a6),
  Color(0xff5d7092),
  Color(0xfff6bd16),
  Color(0xff6f5ef9),
  Color(0xff6dc8ec),
  Color(0xff945fb9),
  Color(0xffff9845),
  Color(0xff1e9493),
  Color(0xffff99c3),
];

//十字准星样式
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

typedef ChartTooltipFormatter = InlineSpan? Function(List<CharBodyState>);

//渲染器， 每次刷新会重新构造，切忌不要存放状态数据，数据都在state里面
abstract class ChartCoordinateRender {
  //图形外边距，用于控制坐标轴的外边距
  final EdgeInsets margin;
  //图形内边距，用于控制坐标轴的内边距
  final EdgeInsets padding;
  //缩放比例
  final bool zoomHorizontal;
  final bool zoomVertical;
  //最小缩放
  final double? minZoom;
  //最大缩放
  final double? maxZoom;
  //坐标系中间的绘图
  final List<ChartBodyRender> charts;
  //自定义提示框的样式
  final TooltipRenderer? tooltipRenderer;
  //用widget弹框来处理点击
  final TooltipWidgetRenderer? tooltipWidgetRenderer;
  //自定义提示文案
  final ChartTooltipFormatter? tooltipFormatter;
  //十字准星样式
  final CrossHairStyle crossHair;
  final EdgeInsets? safeArea;
  //坐标转换工具
  late TransformUtils transformUtils;

  final List<Annotation>? backgroundAnnotations;
  final List<Annotation>? foregroundAnnotations;

  ChartCoordinateRender({
    required this.margin,
    required this.padding,
    required this.charts,
    this.tooltipRenderer,
    this.tooltipFormatter,
    this.tooltipWidgetRenderer,
    this.zoomHorizontal = false,
    this.zoomVertical = false,
    this.minZoom,
    this.maxZoom,
    this.backgroundAnnotations,
    this.foregroundAnnotations,
    this.safeArea,
    this.crossHair = const CrossHairStyle(),
  }) : contentMargin = EdgeInsets.fromLTRB(
            margin.left + padding.left,
            margin.top + padding.top,
            margin.right + padding.right,
            margin.bottom + padding.bottom);

  //共享数据
  late ChartController controller;
  //画布
  late Canvas canvas;
  //画布尺寸
  late Size size;

  //图形内容的外边距信息
  EdgeInsets contentMargin;
  //未处理的坐标  原点在左上角
  Rect get contentRect => Rect.fromLTRB(contentMargin.left, contentMargin.top,
      size.width - contentMargin.left, size.height - contentMargin.bottom);

  void init(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;
    for (var element in charts) {
      element.init(this);
    }
  }

  void scroll(Offset delta);

  void paint(Canvas canvas, Size size);
}
