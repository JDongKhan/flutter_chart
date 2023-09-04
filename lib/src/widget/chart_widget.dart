import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../annotation/annotation.dart';
import '../base/chart_body_render.dart';
import '../base/chart_controller.dart';
import '../base/chart_param.dart';
import '../coordinate/chart_coordinate_render.dart';

/// @author JD
///
typedef TooltipRenderer = void Function(Canvas, Size size, Offset anchor, List<CharBodyState> indexs);
typedef TooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context, List<CharBodyState>);
// typedef ChartCoordinateRenderBuilder = ChartCoordinateRender Function();

///本widget只是起到提供Canvas的功能，不支持任何传参，避免参数来回传递导致难以维护以及混乱，需要自定义可自行去对应渲染器
class ChartWidget extends StatefulWidget {
  ///坐标系
  final ChartCoordinateRender coordinateRender;

  ///控制器
  final ChartController? controller;

  ///处于弹框和chart之间
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

  ChartParam? chartParam;

  @override
  void initState() {
    _controller = widget.controller ?? ChartController();
    super.initState();
  }

  void _defaultOnTapOutside(PointerDownEvent event) {
    /// The focus dropping behavior is only present on desktop platforms
    /// and mobile browsers.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        // On mobile platforms, we don't unfocus on touch events unless they're
        // in the web browser, but we do unfocus for all other kinds of events.
        switch (event.kind) {
          case ui.PointerDeviceKind.touch:
            chartParam?.resetTooltip();
            break;
          case ui.PointerDeviceKind.mouse:
          case ui.PointerDeviceKind.stylus:
          case ui.PointerDeviceKind.invertedStylus:
          case ui.PointerDeviceKind.unknown:
            chartParam?.resetTooltip();
            break;
          case ui.PointerDeviceKind.trackpad:
            throw UnimplementedError('Unexpected pointer down event for trackpad');
        }
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        chartParam?.resetTooltip();
        break;
    }
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
    //谁创建谁管理
    chartParam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(onTapOutside: _defaultOnTapOutside, child: _buildBody());
  }

  Widget _buildBody() {
    //避免和外部的layer合成
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, cs) {
          ChartCoordinateRender baseChart = widget.coordinateRender;
          chartParam?.dispose();
          ChartParam param = ChartParam();
          chartParam = param;
          baseChart.param = param;
          _controller.param = param;
          _controller.chartCoordinateRender = baseChart;
          //关联子状态
          for (int i = 0; i < baseChart.charts.length; i++) {
            ChartBodyRender body = baseChart.charts[i];
            CharBodyState c = CharBodyState();
            body.bodyState = c;
            param.childrenState.add(c);
          }

          Size size = Size(cs.maxWidth, cs.maxHeight);
          List<Widget> childrenWidget = [];
          //图表 chart
          Widget chartWidget = SizedBox(
            width: size.width,
            height: size.height,
            child: _ChartCoreWidget(
              controller: _controller,
              chartCoordinateRender: baseChart,
            ),
          );
          childrenWidget.add(chartWidget);

          //前景组件图层
          if (widget.foregroundWidget != null) {
            childrenWidget.add(widget.foregroundWidget!);
          }
          //弹框图层
          if (baseChart.tooltipBuilder != null) {
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

  ///提示弹框
  Widget _buildTooltipWidget(ChartCoordinateRender baseChart, Size size) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        _controller.param.tooltipStateSetter = setState;
        if (_controller.param.localPosition == null) {
          return const SizedBox.shrink();
        }
        Offset offset = Offset(_controller.param.localPosition?.dx ?? 0, _controller.param.localPosition?.dy ?? 0);

        PreferredSizeWidget? widget = _controller.param.tooltipWidgetBuilder?.call(context);
        TooltipWidgetBuilder? tooltipBuilder = baseChart.tooltipBuilder;
        widget ??= tooltipBuilder?.call(context, _controller.param.childrenState);

        if (widget == null) {
          return const SizedBox.shrink();
        }

        //边界处理
        Rect rect = _adjustRect(
          baseChart,
          Rect.fromLTWH(offset.dx, offset.dy, widget.preferredSize.width, widget.preferredSize.height),
          size,
        );

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
    ChartCoordinateRender baseChart,
    Rect windowRect,
    Size size,
  ) {
    Rect kSafeArea;
    if (baseChart.safeArea != null) {
      kSafeArea = Rect.fromLTRB(baseChart.safeArea!.left, baseChart.safeArea!.top, size.width - baseChart.safeArea!.right, size.height - baseChart.safeArea!.bottom);
    } else {
      kSafeArea = Rect.fromLTRB(0, 0, size.width, size.height);
    }
    final horizontalAdjust =
        windowRect.left < kSafeArea.left ? (kSafeArea.left - windowRect.left) : (windowRect.right > kSafeArea.right ? (kSafeArea.right - windowRect.right) : 0.0);
    final verticalAdjust =
        windowRect.top < kSafeArea.top ? (kSafeArea.top - windowRect.top) : (windowRect.bottom > kSafeArea.bottom ? (kSafeArea.bottom - windowRect.bottom) : 0.0);
    if (horizontalAdjust != 0 || verticalAdjust != 0) {
      windowRect = windowRect.translate(horizontalAdjust, verticalAdjust);
    }

    return windowRect;
  }
}

class _ChartCoreWidget extends StatefulWidget {
  final ChartController controller;
  final ChartCoordinateRender chartCoordinateRender;
  const _ChartCoreWidget({
    Key? key,
    required this.controller,
    required this.chartCoordinateRender,
  }) : super(key: key);

  @override
  State<_ChartCoreWidget> createState() => _ChartCoreWidgetState();
}

class _ChartCoreWidgetState extends State<_ChartCoreWidget> {
  double _beforeZoom = 1.0;
  late Offset _lastOffset;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _ChartCoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.param.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        widget.controller.param.resetTooltip();
        if (!_checkForegroundAnnotationsEvent(details.localPosition)) {
          widget.controller.param.localPosition = details.localPosition;
        }
      },
      onScaleStart: (ScaleStartDetails details) {
        _beforeZoom = widget.controller.param.zoom;
        _lastOffset = widget.controller.param.offset;
        // if (widget.chartCoordinateRender is DimensionsChartCoordinateRender) {
        //   DimensionsChartCoordinateRender render = widget.chartCoordinateRender as DimensionsChartCoordinateRender;
        //   //计算中间值 用于根据手势
        //   centerV = (widget.controller.offset.dx + widget.chartCoordinateRender.size.width / 2) / render.xAxis.density;
        // }
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        widget.controller.param.resetTooltip();
        //缩放
        if (details.scale != 1) {
          if (widget.chartCoordinateRender.zoomHorizontal || widget.chartCoordinateRender.zoomVertical) {
            double minZoom = widget.chartCoordinateRender.minZoom ?? 0;
            double maxZoom = widget.chartCoordinateRender.maxZoom ?? double.infinity;
            double zoom = (_beforeZoom * details.scale).clamp(minZoom, maxZoom);

            // double startOffset = centerV * render.xAxis.density - widget.chartCoordinateRender.size.width / 2;
            //计算缩放和校准偏移
            double startOffset = (_lastOffset.dx + widget.chartCoordinateRender.size.width / 2) * zoom / _beforeZoom - widget.chartCoordinateRender.size.width / 2;
            //用于松手后调整位置边界处理
            widget.controller.scroll(Offset(startOffset, 0));
            widget.controller.param.zoom = zoom;
          }
        } else if (details.pointerCount == 1 && details.scale == 1) {
          widget.controller.scrollByDelta(details.focalPointDelta);
          // widget.controller.localPosition = details.localFocalPoint;
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        //这里可以处理减速的操作
        // print(details.velocity);
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ChartPainter(
            chart: widget.chartCoordinateRender,
          ),
        ),
      ),
    );
  }

  ///判断是否先处理Annotations
  bool _checkForegroundAnnotationsEvent(Offset point) {
    List<Annotation>? foregroundAnnotations = widget.chartCoordinateRender.foregroundAnnotations;
    if (foregroundAnnotations == null) {
      return false;
    }
    for (Annotation annotation in foregroundAnnotations) {
      if (annotation.isRange(point)) {
        annotation.onTap?.call(annotation);
        return true;
      }
    }
    return false;
  }
}

///画图
class _ChartPainter extends CustomPainter {
  final ChartCoordinateRender chart;
  _ChartPainter({
    required this.chart,
  }) : super(repaint: chart.param);

  bool _init = false;
  @override
  void paint(Canvas canvas, Size size) {
    //重置
    for (var element in chart.param.childrenState) {
      element.selectedIndex = null;
    }
    Rect clipRect = Offset.zero & size;
    canvas.clipRect(clipRect);
    //初始化
    if (_init == false) {
      chart.init(size);
      _init = true;
    }
    chart.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    if (oldDelegate.chart != chart) {
      return true;
    }
    ChartParam chartParam = oldDelegate.chart.param;
    ChartParam newChartParam = chart.param;
    if (chartParam != newChartParam) {
      return true;
    }
    return false;
  }
}
