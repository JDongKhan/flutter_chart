import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_chart.dart';

/// @author jd
class ImageAnnotation extends Annotation {
  final ui.Image image;
  final List<num> positions;
  final Offset offset;
  ImageAnnotation({
    required this.image,
    required this.positions,
    super.scroll = true,
    super.yAxisPosition = 0,
    this.offset = Offset.zero,
  });

  //获取网络图片 返回ui.Image
  static Future<ui.Image> getNetImage(String url, {width, height}) async {
    ByteData data = await NetworkAssetBundle(Uri.parse(url)).load(url);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  //获取本地图片 返回ui.Image
  static Future<ui.Image> getAssetImage(String asset, {width, height}) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void draw() {
    if (coordinateChart is LineBarChartCoordinateRender) {
      LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
      num xPo = positions[0];
      num yPo = positions[1];
      double itemWidth = xPo * chart.xAxis.density;
      double itemHeight = yPo * chart.yAxis[yAxisPosition].density;
      double left = chart.contentMargin.left + itemWidth;
      double top = chart.contentRect.bottom - itemHeight;
      if (scroll) {
        left = withXOffset(left);
        left = withXZoom(left);
        top = withYOffset(top);
      } else {
        //不跟随缩放
        if (chart.zoomHorizontal) {
          left = chart.contentMargin.left + itemWidth / chart.state.zoom;
        }
        if (chart.zoomVertical) {
          top = chart.contentRect.bottom - itemHeight / chart.state.zoom;
        }
      }
      Offset offset = Offset(left, top);
      Paint paint = Paint()
        ..color = Colors.blue
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = 30;
      coordinateChart.canvas.drawImage(image, offset.translate(this.offset.dx, this.offset.dy), paint);
    }
  }
}
