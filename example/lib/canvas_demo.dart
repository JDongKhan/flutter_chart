import 'dart:math';

import 'package:flutter/material.dart';

class MyCustomPainter extends CustomPainter {
  final double zoom;
  final Offset offset;
  final List<Offset> pointList;
  MyCustomPainter({
    this.zoom = 1,
    this.offset = Offset.zero,
    required this.pointList,
  });

  // 绘制缩放后的 Path
  Paint linePaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  Paint pointPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0;

  Path? path;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    if (path == null) {
      path = Path();
      // 在 path 中添加绘制路径的逻辑
      int index = 0;
      for (Offset point in pointList) {
        if (index == 0) {
          path?.moveTo(point.dx, point.dy);
        } else {
          path?.lineTo(point.dx, point.dy);
        }
        index++;
      }
    }

    // 创建一个 Transform 来缩放 Path
    final Offset center = Offset(offset.dx, 0); // 缩放中心点
    final Matrix4 matrix = Matrix4.identity()
      ..translate(-center.dx, 0)
      ..scale(zoom, 1);

    Path newPath = path!.transform(matrix.storage); // 应用缩放变换
    canvas.drawPath(newPath, linePaint);

    for (var element in pointList) {
      canvas.drawCircle(element.translate(-center.dx, 0), 2, pointPaint);
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

  late final List<Offset> pointList = List.generate(100000, (index) => Offset(index.toDouble(), Random().nextInt(300).toDouble()));

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
                    // double startOffset = centerV * render.xAxis.density - widget.chartcoordinate.size.width / 2;
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
                    pointList: pointList,
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
