import 'package:flutter/widgets.dart';
import 'package:flutter_chart_plus/src/measure/chart_param.dart';

import '../coordinate/chart_dimensions_coordinate_render.dart';
import '../utils/transform_utils.dart';

class ChartDimensionParam extends ChartParam {
  ///y坐标轴
  final List<YAxis> yAxis;

  ///x坐标轴
  final XAxis xAxis;

  ///缩放比例
  final bool zoomHorizontal;
  final bool zoomVertical;

  ChartDimensionParam.coordinate({
    super.localPosition,
    super.zoom = 1,
    super.offset = Offset.zero,
    required super.childrenState,
    required ChartDimensionsCoordinateRender coordinate,
  })  : yAxis = coordinate.yAxis,
        xAxis = coordinate.xAxis,
        zoomHorizontal = coordinate.zoomHorizontal,
        zoomVertical = coordinate.zoomVertical;

  @override
  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    super.init(size: size, margin: margin, padding: padding);
    //初始化配置
    double width = size.width;
    double height = size.height;
    int count = xAxis.count;
    //每格的宽度，用于控制一屏最多显示个数
    double density = (width - contentMargin.horizontal) / count / xAxis.interval;
    //x轴密度 即1 value 等于多少尺寸
    if (zoomHorizontal) {
      xAxis.density = density * zoom;
    } else {
      xAxis.density = density;
    }
    for (YAxis yA in yAxis) {
      num max = yA.max;
      num min = yA.min;
      int yCount = yA.count;
      //y轴密度  即1 value 等于多少尺寸
      double itemHeight = (height - margin.vertical) / yCount;
      double itemValue = (max - min) / yCount;
      if (zoomVertical) {
        yA.density = itemHeight / itemValue * zoom;
      } else {
        yA.density = itemHeight / itemValue;
      }
    }

    //开始渲染
    //转换工具
    transformUtils = TransformUtils(
      anchor: Offset(margin.left, size.height - margin.bottom),
      zoom: zoom,
      offset: offset,
      size: size,
      zoomVertical: zoomVertical,
      zoomHorizontal: zoomHorizontal,
      padding: padding,
      reverseX: false,
      reverseY: true,
    );
  }

  @override
  Offset scroll(Offset offset) {
    //校准偏移，不然缩小后可能起点都在中间了，或者无限滚动
    double x = offset.dx;
    // double y = newOffset.dy;
    if (x < 0) {
      x = 0;
    }
    //放大的场景  offset会受到zoom的影响，所以这里的宽度要先剔除zoom的影响再比较
    double chartContentWidth = xAxis.density * (xAxis.max ?? xAxis.count);
    double chartViewPortWidth = size.width - contentMargin.horizontal;
    //处理成跟缩放无关的偏移
    double maxOffset = (chartContentWidth - chartViewPortWidth);
    if (maxOffset < 0) {
      //内容小于0
      x = 0;
    } else if (x > maxOffset) {
      x = maxOffset;
    }
    return Offset(x, 0);
  }
}
