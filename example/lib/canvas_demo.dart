import 'package:flutter/material.dart';

class MyCustomPainter extends CustomPainter {
  final double zoom;
  final Offset offset;
  final List poitList = [
    Offset(0, 200),
    Offset(40, 100),
    Offset(100, 120),
    Offset(120, 100),
    Offset(120, 150),
    Offset(200, 100),
    Offset(300, 150),
  ];
  final List<Path> pathList = [];
  MyCustomPainter({
    this.zoom = 1,
    this.offset = Offset.zero,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    // 在 path 中添加绘制路径的逻辑
    print(size);
    int index = 0;
    for (Offset point in poitList) {
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      pathList.add(Path()..addOval(Rect.fromCenter(center: point, width: 2, height: 2)));
      index++;
    }
    print('zoom:$zoom');
    print(offset);
    // 创建一个 Transform 来缩放 Path
    final double scaleFactor = zoom; // 缩放因子
    final Offset center = Offset(offset.dx, 0); // 缩放中心点
    final Matrix4 matrix = Matrix4.identity()
      ..translate(-center.dx, 0)
      ..scale(zoom, 1);

    path = path.transform(matrix.storage); // 应用缩放变换

    // 绘制缩放后的 Path
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, paint);

    paint.color = Colors.red;

    final Matrix4 matrix2 = Matrix4.identity()..translate(-center.dx, 0);

    for (var element in pathList) {
      path = element.transform(matrix.storage); // 应用缩放变换
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyCustomWidget extends StatefulWidget {
  const MyCustomWidget({super.key});

  @override
  State<MyCustomWidget> createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
  late double _beforeZoom;
  double _zoom = 1;
  late Offset _lastOffset;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Path 缩放'),
      ),
      body: Center(
        child: Container(
          color: Colors.red.withOpacity(0.1),
          height: 300,
          width: 300,
          child: LayoutBuilder(
            builder: (context, cs) {
              Size size = Size(cs.maxWidth, cs.maxHeight);
              return GestureDetector(
                onScaleStart: (ScaleStartDetails details) {
                  _beforeZoom = _zoom;
                  _lastOffset = _offset;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  //缩放
                  if (details.scale != 1) {
                    double zoom = (_beforeZoom * details.scale);
                    // double startOffset = centerV * render.xAxis.density - widget.chartCoordinateRender.size.width / 2;
                    //计算缩放和校准偏移
                    double startOffset = (_lastOffset.dx + size.width / 2) * zoom / _beforeZoom - size.width / 2;
                    _zoom = zoom;
                    _offset = Offset(startOffset, 0);
                    setState(() {});
                  } else if (details.pointerCount == 1 && details.scale == 1) {
                    _offset = _offset.translate(-details.focalPointDelta.dx, -details.focalPointDelta.dy);
                    setState(() {});
                  }
                },
                child: CustomPaint(
                  painter: MyCustomPainter(
                    zoom: _zoom,
                    offset: _offset,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyCustomWidget(),
  ));
}
