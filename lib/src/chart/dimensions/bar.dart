import 'package:flutter/material.dart';

import '../../param/chart_dimension_param.dart';
import '../../param/chart_param.dart';
import '../../utils/chart_utils.dart';
import '../../base/chart_body_render.dart';
import '../../param/chart_layout_param.dart';

typedef BarPosition<T> = num Function(T);

/// @author JD
///普通bar
class Bar<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///bar的宽度
  final double itemWidth;

  ///值格式化 不要使用过于耗时的方法
  final BarPosition value;

  ///颜色
  final Color color;

  ///优先级高于color
  final Shader? shader;

  ///高亮颜色
  final Color highlightColor;

  Bar({
    required super.data,
    required this.value,
    required this.position,
    super.yAxisPosition,
    this.itemWidth = 20,
    this.color = Colors.blue,
    this.shader,
    this.highlightColor = Colors.yellow,
  });

  final Paint _paint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void draw(Canvas canvas, ChartParam param) {
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (int index = 0; index < data.length; index++) {
      T item = data[index];
      num xPoV = position.call(item);
      num yPoV = value.call(item);
      ChartLayoutParam p = _measureBarLayoutParam(param, xPoV, yPoV)..index = index;
      if (p.rect != null) {
        if (p.hitTest(param.localPosition)) {
          layoutParam.selectedIndex = index;
          _paint.shader = null;
          _paint.color = highlightColor;
        } else {
          if (shader != null) {
            _paint.shader = shader;
          } else {
            _paint.color = color;
          }
        }
        //开始绘制，bar不同于line，在循环中就可以绘制
        canvas.drawRect(p.rect!, _paint);
      }
      childrenLayoutParams.add(p);
    }
    layoutParam.children = childrenLayoutParams;
  }

  //可以重写 自定义特殊的图形
  ChartLayoutParam _measureBarLayoutParam(ChartParam param, num xPoV, num yPoV) {
    param as ChartDimensionParam;
    if (yPoV == 0) {
      return ChartLayoutParam();
    }
    double bottom = param.size.height - param.contentMargin.bottom;
    double contentHeight = param.size.height - param.contentMargin.vertical;

    double left = param.contentMargin.left + param.xAxis.density * xPoV - itemWidth / 2;
    left = param.transformUtils.withXOffset(left);

    double present = yPoV / param.yAxis[yAxisPosition].max;
    double itemHeight = contentHeight * present * param.controlValue;
    double top = bottom - itemHeight;
    if (left > param.size.width || (left + itemWidth) < 0) {
      return ChartLayoutParam();
    }
    Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
    ChartLayoutParam shape = ChartLayoutParam.rect(
      rect: rect,
    );
    return shape;
  }
}

typedef StackBarPosition<T> = List<num> Function(T);

///stackBar  支持水平/垂直排列
class StackBar<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///值格式化
  final StackBarPosition<T> values;

  ///bar的宽度
  final double itemWidth;

  ///多个颜色
  final List<Color> colors;

  ///优先级高于colors
  final List<Shader>? shaders;

  ///高亮颜色
  final Color highlightColor;

  ///方向
  final Axis direction;

  ///撑满 如果为true则会根据实际数值的总和求比例，如果为false则会根据Y轴最大值求比例
  final bool full;

  ///绘制热区 颜色
  final Color? hotColor;

  ///两个bar之间的间距
  final double padding;

  StackBar({
    required super.data,
    required this.position,
    required this.values,
    super.yAxisPosition = 0,
    this.highlightColor = Colors.yellow,
    this.colors = colors10,
    this.shaders,
    this.itemWidth = 20,
    this.direction = Axis.horizontal,
    this.full = false,
    this.padding = 5,
    this.hotColor,
  });

  final Paint _paint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  late final Paint _hotPaint = Paint()..style = PaintingStyle.fill;

  @override
  void draw(Canvas canvas, ChartParam param) {
    param as ChartDimensionParam;
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (int index = 0; index < data.length; index++) {
      T item = data[index];
      num po = position.call(item);
      List<num> vas = values.call(item);
      assert(colors.length >= vas.length);
      assert(shaders == null || shaders!.length >= vas.length);
      ChartLayoutParam p;
      if (direction == Axis.horizontal) {
        p = _measureHorizontalBarLayoutParam(param, po, vas);
      } else {
        p = _measureVerticalBarLayoutParam(param, po, vas);
      }
      childrenLayoutParams.add(p..index = index);

      int stackIndex = 0;
      for (ChartLayoutParam cp in p.children) {
        if (cp.rect != null) {
          if (shaders != null) {
            _paint.shader = shaders![stackIndex];
          } else {
            _paint.color = colors[stackIndex];
          }
          if (cp.hitTest(param.localPosition)) {
            layoutParam.selectedIndex = index;
            _paint.shader = null;
            _paint.color = highlightColor;
          }
          //画图
          canvas.drawRect(cp.rect!, _paint);
        }
        stackIndex++;
      }

      //绘制热区
      if (hotColor != null && p.rect != null) {
        canvas.drawRect(
          p.rect!,
          _hotPaint..color = hotColor!,
        );
      }
    }
    layoutParam.children = childrenLayoutParams;
  }

  ///水平排列图形
  ChartLayoutParam _measureHorizontalBarLayoutParam(ChartDimensionParam param, num po, List<num> vas) {
    num total = param.yAxis[yAxisPosition].max;
    if (total == 0) {
      return ChartLayoutParam();
    }
    double bottom = param.size.height - param.contentMargin.bottom;
    double contentHeight = param.size.height - param.contentMargin.vertical;

    double center = vas.length * itemWidth / 2;

    double left = param.contentMargin.left + param.xAxis.density * po - itemWidth / 2 - center;
    left = param.transformUtils.withXOffset(left);

    ChartLayoutParam shape = ChartLayoutParam.rect(
      rect: Rect.fromLTWH(
        left,
        param.contentMargin.top,
        itemWidth * vas.length + padding * (vas.length - 1),
        param.size.height - param.contentMargin.vertical,
      ),
    );
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (num v in vas) {
      double present = v / total;
      double itemHeight = contentHeight * present * param.controlValue;
      double top = bottom - itemHeight;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartLayoutParam stackShape = ChartLayoutParam.rect(rect: rect);
      left = left + itemWidth + padding;
      childrenLayoutParams.add(stackShape);
    }
    shape.children = childrenLayoutParams;
    return shape;
  }

  ///垂直排列图形
  ChartLayoutParam _measureVerticalBarLayoutParam(ChartDimensionParam param, num po, List<num> vas) {
    num total = param.yAxis[yAxisPosition].max;
    if (full) {
      total = vas.fold(0, (previousValue, element) => previousValue + element);
    }
    if (total == 0) {
      return ChartLayoutParam();
    }
    double bottom = param.size.height - param.contentMargin.bottom;
    double contentHeight = param.size.height - param.contentMargin.vertical;
    double left = param.contentMargin.left + param.xAxis.density * po - itemWidth / 2;
    left = param.transformUtils.withXOffset(left);
    ChartLayoutParam shape = ChartLayoutParam.rect(
      rect: Rect.fromLTWH(
        left,
        param.contentMargin.top,
        itemWidth,
        param.size.height - param.contentMargin.vertical,
      ),
    );
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (num v in vas) {
      double present = v / total;
      double itemHeight = contentHeight * present * param.controlValue;
      double top = bottom - itemHeight;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartLayoutParam stackShape = ChartLayoutParam.rect(rect: rect);
      childrenLayoutParams.add(stackShape);
      bottom = top;
    }
    shape.children = childrenLayoutParams;
    return shape;
  }
}
