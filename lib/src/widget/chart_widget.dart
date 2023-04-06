import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_controller.dart';
import '../base/chart_coordinate_render.dart';

/// @author JD
///
typedef TooltipRenderer = void Function(
    Canvas, Size size, Offset anchor, List<CharBodyState> indexs);
typedef TooltipWidgetRenderer = PreferredSizeWidget? Function(
    BuildContext context, List<CharBodyState>);
// typedef ChartCoordinateRenderBuilder = ChartCoordinateRender Function();

//本widget只是起到提供Canvas的功能，不支持任何传参，避免参数来回传递导致难以维护以及混乱，需要自定义可自行去对应渲染器
class ChartWidget extends StatefulWidget {
  final ChartCoordinateRender coordinateRender;
  final ChartController? controller;
  //处于弹框和chart之间
  final Widget? foregroundWidget;
  const ChartWidget({
    Key? key,
    required this.coordinateRender,
    this.controller,
    this.foregroundWidget,
  }) : super(key: key);
  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  late ChartController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? ChartController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null) {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.tooltipStateSetter = null;
    return _buildBody();
  }

  Widget _buildBody() {
    //避免和外部的layer合成
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, cs) {
          ChartCoordinateRender baseChart = widget.coordinateRender;
          baseChart.controller = _controller;

          _controller.childrenState.clear();
          //关联子状态
          for (int i = 0; i < baseChart.charts.length; i++) {
            ChartBodyRender body = baseChart.charts[i];
            CharBodyState c = CharBodyState(_controller);
            body.bodyState = c;
            _controller.childrenState.add(c);
          }

          Size size = Size(cs.maxWidth, cs.maxHeight);

          List<Widget> childrenWidget = [];
          //图表 chart
          Widget chartWidget = _ChartCoreWidget(
            size: size,
            controller: _controller,
            chartCoordinateRender: baseChart,
          );
          childrenWidget.add(chartWidget);

          //前景组件图层
          if (widget.foregroundWidget != null) {
            childrenWidget.add(widget.foregroundWidget!);
          }
          //弹框图层
          if (baseChart.tooltipWidgetRenderer != null) {
            childrenWidget.add(_buildTooltipWidget(baseChart, size));
          }
          if (childrenWidget.length > 1) {
            return Stack(
              children: childrenWidget,
            );
          }
          return chartWidget;
        },
      ),
    );
  }

  Widget _buildTooltipWidget(ChartCoordinateRender baseChart, Size size) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        _controller.tooltipStateSetter = setState;
        if (_controller.localPosition == null) {
          return const SizedBox.shrink();
        }
        Offset offset = Offset(_controller.localPosition?.dx ?? 0,
            _controller.localPosition?.dy ?? 0);

        PreferredSizeWidget? widget = baseChart.tooltipWidgetRenderer!
            .call(context, _controller.childrenState);

        if (widget == null) {
          return const SizedBox.shrink();
        }

        //边界处理
        Rect rect = _adjustRect(
            Rect.fromLTWH(offset.dx, offset.dy, widget.preferredSize.width,
                widget.preferredSize.height),
            size);

        return Positioned(
          left: rect.left,
          top: rect.top,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66cecece),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: widget,
          ),
        );
      },
    );
  }

  Rect _adjustRect(
    Rect windowRect,
    Size size,
  ) {
    Rect kSafeArea = Rect.fromLTRB(0, 0, size.width, size.height);
    final horizontalAdjust = windowRect.left < kSafeArea.left
        ? (kSafeArea.left - windowRect.left)
        : (windowRect.right > kSafeArea.right
            ? (kSafeArea.right - windowRect.right)
            : 0.0);
    final verticalAdjust = windowRect.top < kSafeArea.top
        ? (kSafeArea.top - windowRect.top)
        : (windowRect.bottom > kSafeArea.bottom
            ? (kSafeArea.bottom - windowRect.bottom)
            : 0.0);
    if (horizontalAdjust != 0 || verticalAdjust != 0) {
      windowRect = windowRect.translate(horizontalAdjust, verticalAdjust);
    }

    return windowRect;
  }
}

class _ChartCoreWidget extends StatefulWidget {
  final Size size;
  final ChartController controller;
  final ChartCoordinateRender chartCoordinateRender;
  const _ChartCoreWidget({
    Key? key,
    required this.size,
    required this.controller,
    required this.chartCoordinateRender,
  }) : super(key: key);

  @override
  State<_ChartCoreWidget> createState() => _ChartCoreWidgetState();
}

class _ChartCoreWidgetState extends State<_ChartCoreWidget> {
  Offset offset = Offset.zero;
  double zoom = 1.0;
  double _beforeZoom = 1.0;

  bool needRepaint = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _ChartCoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reset();
  }

  void _reset() {
    zoom = 1.0;
    widget.controller.zoom = 1.0;
    widget.controller.localPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    //重置
    for (var element in widget.controller.childrenState) {
      element.selectedIndex = null;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        widget.controller.localPosition = details.localPosition;
        needRepaint = true;
        setState(() {});
      },
      onScaleStart: (ScaleStartDetails details) {
        _beforeZoom = zoom;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        //缩放
        if (details.scale != 1) {
          //先清除手势
          widget.controller.clearPosition();
          if (widget.chartCoordinateRender.zoomHorizontal ||
              widget.chartCoordinateRender.zoomVertical) {
            setState(() {
              needRepaint = true;
              zoom = _beforeZoom * details.scale;
              double minZoom = widget.chartCoordinateRender.minZoom ?? 0;
              double maxZoom =
                  widget.chartCoordinateRender.maxZoom ?? double.infinity;
              if (zoom < minZoom) {
                zoom = minZoom;
              } else if (zoom > maxZoom) {
                zoom = maxZoom;
              }
              widget.controller.zoom = zoom;
            });
          }
        } else if (details.pointerCount == 1 && details.scale == 1) {
          //移动
          widget.chartCoordinateRender
              .scroll(details.focalPointDelta / widget.controller.zoom);
          // widget.controller.localPosition = details.localFocalPoint;
          setState(() {
            needRepaint = true;
          });
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        //这里可以处理减速的操作
        needRepaint = false;
        // print(details.velocity);
      },
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ChartPainter(
              repaint: repaint(),
              chart: widget.chartCoordinateRender,
            ),
          ),
        ),
      ),
    );
  }

  //是否重绘
  bool repaint() {
    bool localRepaint = needRepaint;
    needRepaint = false;
    return localRepaint;
  }
}

//画图
class _ChartPainter extends CustomPainter {
  final ChartCoordinateRender chart;
  final bool repaint;
  _ChartPainter({
    required this.chart,
    this.repaint = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //初始化
    chart.init(canvas, size);
    chart.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    if (oldDelegate.chart != chart) {
      return true;
    }
    ChartController oldController = oldDelegate.chart.controller;
    ChartController newController = chart.controller;
    if (oldController != newController) {
      return true;
    }
    return repaint;
  }
}
