part of flutter_chart_plus;

/// @author jd
class ImageAnnotation extends Annotation {
  ///图片
  final ui.Image image;

  ///两个长度的数组，优先级最高，ImageAnnotation的位置，对应xy轴的value
  final List<num>? positions;

  ///设置ImageAnnotation的偏移，忽略positions的设置
  final Offset Function(Size)? anchor;

  ///偏移，可以做细微调整
  final Offset offset;

  ImageAnnotation({
    super.userInfo,
    super.onTap,
    super.fixed = false,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    this.anchor,
    required this.image,
    this.positions,
    this.offset = Offset.zero,
  }) : assert(positions != null || anchor != null, 'positions or anchor must be not null');

  ///获取网络图片 返回ui.Image
  static Future<ui.Image> getNetImage(String url, {width, height}) async {
    ByteData data = await NetworkAssetBundle(Uri.parse(url)).load(url);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  ///获取本地图片 返回ui.Image
  static Future<ui.Image> getAssetImage(String asset, {width, height}) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void draw(Canvas canvas, ChartsState param) {
    if (!isNeedDraw(param)) {
      return;
    }
    ChartCoordinateParam layout = param.layout;
    if (layout is _ChartDimensionCoordinateParam) {
      Offset ost;
      if (positions != null) {
        assert(positions!.length == 2, 'positions must be two length');
        num xValue = positions![0];
        num yPo = positions![1];
        double xPos = layout.xAxis.getItemWidth(xValue, fixed);
        double yPos = layout.yAxis[yAxisPosition].getItemHeight(yPo, fixed);
        ost = layout.transform.transformPoint(Offset(xPos, yPos), containPadding: true, xOffset: !fixed, yOffset: !fixed);
      } else {
        ost = anchor!(param.layout.size);
      }
      Paint paint = Paint()..isAntiAlias = true;
      canvas.drawImage(image, ost.translate(offset.dx - image.width / 2, offset.dy - image.height / 2), paint);
      Rect rect = Rect.fromCenter(center: Offset(ost.dx, ost.dy), width: image.width.toDouble(), height: image.height.toDouble());
      super.rect = rect;
    }
  }
}
