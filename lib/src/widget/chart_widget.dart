import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_coordinate_render.dart';
import '../base/chart_state.dart';

/// @author JD
///
typedef TooltipRenderer = void Function(Canvas, Size size, Offset anchor, List<int?> indexs);
typedef ChartCoordinateRenderBuilder = ChartCoordinateRender Function();

//本widget只是起到提供Canvas的功能，不支持任何传参，避免参数来回传递导致难以维护以及混乱，需要自定义可自行去对应渲染器
class ChartWidget extends StatefulWidget {
  final ChartCoordinateRenderBuilder builder;
  const ChartWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);
  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  Offset offset = Offset.zero;
  double zoom = 1.0;
  double _beforeZoom = 1.0;
  late ChartState _state;

  @override
  void initState() {
    _state = ChartState();
    _registerChanged();
    super.initState();
  }

  void _registerChanged() {
    _state.addListener(_update);
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant ChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state.removeListener(_update);
    _state.dispose();
    _state = ChartState();
    _update();
  }

  @override
  void dispose() {
    _state.removeListener(_update);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cs) {
      ChartCoordinateRender baseChart = widget.builder.call();
      baseChart.state = _state;
      for (int i = 0; i < baseChart.charts.length; i++) {
        ChartBodyRender body = baseChart.charts[i];
        body.positionIndex = i;
        CharBodyState? c = _state.bodyStateList[i];
        if (c == null) {
          c = CharBodyState();
          _state.bodyStateList[i] = c;
        }
        body.bodyState = c;
      }

      return _buildWidget(baseChart, cs.maxWidth, cs.maxHeight);
    });
  }

  Widget _buildWidget(ChartCoordinateRender chart, double width, double height) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        _state.gesturePoint = details.localPosition;
        setState(() {});
      },
      onScaleStart: (ScaleStartDetails details) {
        _beforeZoom = zoom;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        //缩放
        if (details.scale != 1) {
          if (chart.zoomHorizontal || chart.zoomVertical) {
            setState(() {
              zoom = _beforeZoom * details.scale;
              _state.zoom = zoom;
            });
          }
        } else if (details.pointerCount == 1 && details.scale == 1) {
          //移动
          chart.scroll(details.focalPointDelta);
          setState(() {});
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        //这里可以处理减速的操作
        // print(details.velocity);
      },
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ChartPainter(
            chart: chart,
          ),
        ),
      ),
    );
  }
}

//画图
class _ChartPainter extends CustomPainter {
  final ChartCoordinateRender chart;
  _ChartPainter({
    required this.chart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    chart.state.bodyStateList.forEach((key, value) {
      value.selectedIndex = null;
    });
    //初始化
    chart.init(canvas, size);
    chart.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.chart != chart;
}
