import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_chart.dart';

/// @author jd
class ImageAnnotation extends Annotation {
  final ui.Image image;
  final List<num>? positions;
  final Offset Function(Size)? anchor;
  final Offset offset;
  ImageAnnotation({
    super.userInfo,
    super.onTap,
    super.scroll = true,
    super.yAxisPosition = 0,
    this.anchor,
    required this.image,
    this.positions,
    this.offset = Offset.zero,
  }) : assert(positions != null || anchor != null);

  //获取网络图片 返回ui.Image
  static Future<ui.Image> getNetImage(String url, {width, height}) async {
    ByteData data = await NetworkAssetBundle(Uri.parse(url)).load(url);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  //获取本地图片 返回ui.Image
  static Future<ui.Image> getAssetImage(String asset, {width, height}) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void draw(final Offset offset) {
    if (coordinateChart is DimensionsChartCoordinateRender) {
      DimensionsChartCoordinateRender chart =
          coordinateChart as DimensionsChartCoordinateRender;
      Offset ost;
      if (positions != null) {
        num xPo = positions![0];
        num yPo = positions![1];
        double itemWidth = xPo * chart.xAxis.density;
        double itemHeight = yPo * chart.yAxis[yAxisPosition].density;
        ost = chart.transformUtils.withZoomOffset(
          Offset(
            chart.transformUtils.transformX(itemWidth, containPadding: true),
            chart.transformUtils.transformY(itemHeight, containPadding: true),
          ),
          scroll,
        );
      } else {
        ost = anchor!(chart.size);
      }
      Paint paint = Paint()..isAntiAlias = true;
      coordinateChart.canvas.drawImage(
          image,
          ost.translate(
            this.offset.dx - image.width / 2,
            this.offset.dy - image.height / 2,
          ),
          paint);
      Rect rect = Rect.fromCenter(
        center: Offset(ost.dx, ost.dy),
        width: image.width.toDouble(),
        height: image.height.toDouble(),
      );
      if (chart.controller.localPosition != null &&
          rect.contains(chart.controller.localPosition!)) {
        Future.microtask(() => onTap?.call(this));
      }
    }
  }
}
