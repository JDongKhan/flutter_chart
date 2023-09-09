import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../annotation/annotation.dart';
import '../base/chart_body_render.dart';
import '../base/chart_controller.dart';
import '../param/chart_param.dart';
import '../param/chart_layout_param.dart';
import '../coordinate/chart_coordinate_render.dart';

/// @author JD
///
typedef TooltipRenderer = void Function(Canvas, Size size, Offset anchor, List<ChartLayoutParam> indexs);
typedef TooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context, List<ChartLayoutParam>);
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
            _controller.resetTooltip();
            break;
          case ui.PointerDeviceKind.mouse:
          case ui.PointerDeviceKind.stylus:
          case ui.PointerDeviceKind.invertedStylus:
          case ui.PointerDeviceKind.unknown:
            _controller.resetTooltip();
            break;
          case ui.PointerDeviceKind.trackpad:
            throw UnimplementedError('Unexpected pointer down event for trackpad');
        }
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        _controller.resetTooltip();
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
    super.dispose();
    _controller.detach();
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
          _controller.attach(baseChart);
          Size size = Size(cs.maxWidth, cs.maxHeight);
          List<Widget> childrenWidget = [];
          //图表 chart
          Widget chartWidget = SizedBox(
            width: size.width,
            height: size.height,
            child: _ChartCoreWidget(
              size: size,
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
        _controller.tooltipStateSetter = setState;
        Offset? point = _controller.tapPosition ?? _controller.localPosition;
        if (point == null) {
          return const SizedBox.shrink();
        }
        Offset offset = Offset(point.dx, point.dy);

        PreferredSizeWidget? widget = _controller.tooltipWidgetBuilder?.call(context);
        TooltipWidgetBuilder? tooltipBuilder = baseChart.tooltipBuilder;
        widget ??= tooltipBuilder?.call(context, _controller.chartParam);

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
  final ChartCoordinateRender chartCoordinateRender;
  final Size size;
  const _ChartCoreWidget({
    Key? key,
    required this.size,
    required this.chartCoordinateRender,
  }) : super(key: key);

  @override
  State<_ChartCoreWidget> createState() => _ChartCoreWidgetState();
}

class _ChartCoreWidgetState extends State<_ChartCoreWidget> with SingleTickerProviderStateMixin {
  double _beforeZoom = 1.0;
  late Offset _lastOffset;
  late ChartParam _chartParam;
  get _controller => widget.chartCoordinateRender.controller;
  late List<ChartLayoutParam> allParams;
  AnimationController? _animationController;
  @override
  void initState() {
    if (widget.chartCoordinateRender.animal) {
      _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
      _animationController?.addListener(() {
        setState(() {});
      });
    }
    _initState();
    super.initState();
  }

  void _initState() {
    _animationController?.forward();
    allParams = [];
    List<ChartBodyRender> charts = widget.chartCoordinateRender.charts;
    //关联子状态
    for (int i = 0; i < charts.length; i++) {
      ChartBodyRender body = charts[i];
      ChartLayoutParam c = ChartLayoutParam();
      c.left = 0;
      c.right = widget.size.width;
      body.layoutParam = c;
      allParams.add(c);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _ChartCoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initState();
  }

  @override
  Widget build(BuildContext context) {
    _chartParam = ChartParam.coordinate(
      outDraw: widget.chartCoordinateRender.outDraw,
      childrenState: allParams,
      coordinate: widget.chartCoordinateRender,
      controlValue: _animationController?.value ?? 1,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        _controller.resetTooltip();
        Offset? localPosition;
        if (!_checkForegroundAnnotationsEvent(details.localPosition)) {
          localPosition = details.localPosition;
        } else {
          localPosition = null;
        }
        _chartParam.localPosition = localPosition;
      },
      onScaleStart: (ScaleStartDetails details) {
        _beforeZoom = _chartParam.zoom;
        _lastOffset = _chartParam.offset;
        // if (widget.chartCoordinateRender is DimensionsChartCoordinateRender) {
        //   DimensionsChartCoordinateRender render = widget.chartCoordinateRender as DimensionsChartCoordinateRender;
        //   //计算中间值 用于根据手势
        //   centerV = (widget.controller.offset.dx + widget.chartCoordinateRender.size.width / 2) / render.xAxis.density;
        // }
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        _controller.resetTooltip();
        //缩放
        if (details.scale != 1) {
          if (widget.chartCoordinateRender.zoomHorizontal || widget.chartCoordinateRender.zoomVertical) {
            double minZoom = widget.chartCoordinateRender.minZoom ?? 0;
            double maxZoom = widget.chartCoordinateRender.maxZoom ?? double.infinity;
            double zoom = (_beforeZoom * details.scale).clamp(minZoom, maxZoom);

            // double startOffset = centerV * render.xAxis.density - widget.chartCoordinateRender.size.width / 2;
            //计算缩放和校准偏移
            double startOffset = (_lastOffset.dx + _chartParam.size.width / 2) * zoom / _beforeZoom - _chartParam.size.width / 2;
            _chartParam.zoom = zoom;
            scroll(Offset(startOffset, 0));
          }
        } else if (details.pointerCount == 1 && details.scale == 1) {
          scrollByDelta(details.focalPointDelta);
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
            param: _chartParam,
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

  void scrollByDelta(Offset delta) {
    Offset newOffset = _chartParam.offset.translate(-delta.dx, -delta.dy);
    scroll(newOffset);
  }

  void scroll(Offset offset) {
    _chartParam.scroll(offset);
  }

  // void hitTest(Offset point) {
  //   List<ChartBodyRender> charts = widget.chartCoordinateRender.charts;
  //   //关联子状态
  //   for (int i = 0; i < charts.length; i++) {
  //     ChartBodyRender body = charts[i];
  //     //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
  //     ChartShapeLayoutParam layoutParam = body.layoutParam;
  //     layoutParam.selectedIndex = null;
  //     List<ChartShapeLayoutParam> childrenLayoutParams = body.layoutParam.children;
  //     for (int index = 0; index < childrenLayoutParams.length; index++) {
  //       if ((childrenLayoutParams[index].hitTest(point) == true)) {
  //         layoutParam.selectedIndex = index;
  //       }
  //     }
  //   }
  // }
}

///画图
class _ChartPainter extends CustomPainter {
  final ChartCoordinateRender chart;
  final ChartParam param;
  _ChartPainter({
    required this.chart,
    required this.param,
  }) : super(repaint: param);

  @override
  void paint(Canvas canvas, Size size) {
    chart.controller.bindParam(param);
    for (var element in param.childrenState) {
      element.selectedIndex = null;
    }
    Rect clipRect = Offset.zero & size;
    canvas.clipRect(clipRect);
    param.init(size: size, margin: chart.margin, padding: chart.padding);
    chart.paint(canvas, param);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    if (oldDelegate.chart != chart) {
      return true;
    }
    ChartParam chartParam = oldDelegate.param;
    ChartParam newChartParam = param;
    if (chartParam != newChartParam) {
      return true;
    }
    return false;
  }
}
