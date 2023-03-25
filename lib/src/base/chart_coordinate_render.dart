import 'package:flutter/material.dart';

import '../annotation/annotation.dart';
import '../widget/chart_widget.dart';
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

typedef ChartPosition<T> = num Function(T);
typedef ChartTooltipFormatter<T> = InlineSpan Function(T);

//渲染器， 每次刷新会重新构造，切忌不要存放状态数据，数据都在controller里面
abstract class ChartCoordinateRender<T> {
  //图形外边距，用于控制两轴边距
  final EdgeInsets margin;
  //图形内边距，用于控制图形内容距两周的距离
  final EdgeInsets padding;
  //数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;
  //缩放比例
  final bool zoom;
  //数据源 目前只支持x坐标相同的多条数据
  final List<T> data;
  //坐标系中间的绘图
  final ChartRender<T> chartRender;
  //自定义提示框的样式
  final TooltipRenderer? tooltipRenderer;
  //自定义提示文案
  final ChartTooltipFormatter<T>? tooltipFormatter;
  //十字准星样式
  final CrossHairStyle crossHair;

  final List<Annotation>? backgroundAnnotations;
  final List<Annotation>? foregroundAnnotations;

  ChartCoordinateRender({
    required this.margin,
    required this.padding,
    required this.position,
    required this.chartRender,
    required this.data,
    this.tooltipRenderer,
    this.tooltipFormatter,
    this.zoom = false,
    this.backgroundAnnotations,
    this.foregroundAnnotations,
    this.crossHair = const CrossHairStyle(),
  }) : contentMargin = EdgeInsets.fromLTRB(margin.left + padding.left, margin.top + padding.top, margin.right + padding.right, margin.bottom + padding.bottom);

  //共享数据
  late ChartController controller;
  //画布
  late Canvas canvas;
  //画布尺寸
  late Size size;

  //图形内容的外边距信息
  EdgeInsets contentMargin;
  Rect get contentRect => Rect.fromLTRB(contentMargin.left, contentMargin.top, size.width - contentMargin.left, size.height - contentMargin.bottom);

  void init(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;
    chartRender.init(this);
  }

  double withXOffset(double offset, [bool scrollable = true]) {
    if (scrollable) {
      return offset - controller.offset.dx;
    }
    return offset;
  }

  double withXZoom(double offset) {
    return offset - (controller.zoom - 1) * (size.width / 2);
  }

  double withYOffset(double offset, [bool scrollable = true]) {
    if (scrollable) {
      return offset - controller.offset.dy;
    }
    return offset;
  }

  void scroll(Offset offset);

  void paint(Canvas canvas, Size size);
}

abstract class ChartRender<T> {
  ChartRender();
  //坐标系
  late ChartCoordinateRender<T> coordinateChart;

  //初始化
  void init(ChartCoordinateRender<T> coordinateChart) {
    this.coordinateChart = coordinateChart;
  }

  double withXOffset(double offset, [bool scrollable = true]) {
    return coordinateChart.withXOffset(offset, scrollable);
  }

  double withXZoom(double offset) {
    return coordinateChart.withXZoom(offset);
  }

  double withYOffset(double offset, [bool scrollable = true]) {
    return coordinateChart.withYOffset(offset, scrollable);
  }

  void draw();
}
