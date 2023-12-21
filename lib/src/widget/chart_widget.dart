part of flutter_chart_plus;

/// @author JD
///
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
    } else if (widget.coordinateRender.hasChange(oldWidget.coordinateRender)) {
      //因外部动态布局，因缓存的问题，可能会导致state被重用，所以发现类型不一样就重置  如果类型一样，但是图表数量不一样了 也重置，
      _controller = ChartController();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: _defaultOnTapOutside,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    //避免和外部的layer合成
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, cs) {
          ChartCoordinateRender baseChart = widget.coordinateRender;
          _controller._attach(baseChart);
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
        _controller._bindTooltipStateSetter(setState);
        Offset? point = _controller.outTapLocation ?? _controller.localPosition;
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

class _ChartCoreWidgetState extends State<_ChartCoreWidget> with TickerProviderStateMixin {
  double _beforeZoom = 1.0;
  late Offset _lastOffset;
  late ChartsParam _chartParam;
  get _controller => widget.chartCoordinateRender.controller;
  late List<ChartLayoutParam> allParams;
  AnimationController? _animationController;
  @override
  void initState() {
    if (widget.chartCoordinateRender.animationDuration != null) {
      _animationController = AnimationController(vsync: this, duration: widget.chartCoordinateRender.animationDuration);
      _animationController?.addListener(() {
        setState(() {});
      });
    }
    _initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startAnimal();
    });
    super.initState();
  }

  void _initState() {
    allParams = [];
    List<ChartBodyRender> charts = widget.chartCoordinateRender.charts;
    //关联子状态
    for (int i = 0; i < charts.length; i++) {
      ChartBodyRender body = charts[i];
      ChartLayoutParam c = ChartLayoutParam();
      c.left = 0;
      c.index = i;
      c.right = widget.size.width;
      //还原状态
      body.isInit = false;
      body.layout = c;
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
    _startAnimal();
  }

  void _startAnimal() {
    _animationController?.reset();
    _animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    _chartParam = ChartsParam.coordinate(
      outDraw: widget.chartCoordinateRender.outDraw,
      childrenState: allParams,
      coordinate: widget.chartCoordinateRender,
      controlValue: _animationController?.value ?? 1,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        _controller.resetTooltip();
        if (!_checkForegroundAnnotationsEvent(details.localPosition)) {
          Offset localPosition = details.localPosition;
          hitTest(localPosition);
          _chartParam.localPosition = localPosition;
        } else {
          _chartParam.localPosition = null;
        }
      },
      onScaleStart: (ScaleStartDetails details) {
        _beforeZoom = _chartParam.layout.zoom;
        _lastOffset = _chartParam.layout.offset;
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
          if (widget.chartCoordinateRender.canZoom()) {
            double minZoom = widget.chartCoordinateRender.minZoom ?? 0;
            double maxZoom = widget.chartCoordinateRender.maxZoom ?? double.infinity;
            double zoom = (_beforeZoom * details.scale).clamp(minZoom, maxZoom);

            // double startOffset = centerV * render.xAxis.density - widget.chartCoordinateRender.size.width / 2;
            //计算缩放和校准偏移  暂不支持垂直方向缩放，因为应该很少有这个需求
            double startOffset = (_lastOffset.dx + _chartParam.layout.size.width / 2) * zoom / _beforeZoom - _chartParam.layout.size.width / 2;
            _chartParam.zoom = zoom;
            _chartParam.scroll(Offset(startOffset, 0));
          }
        } else if (details.pointerCount == 1 && details.scale == 1) {
          _chartParam.scrollByDelta(details.focalPointDelta);
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        //这里可以处理减速的操作
        // _startDecelerationAnimation(details.velocity.pixelsPerSecond.dx);
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

  // AnimationController? _scrollAnimationController;

  // void _startDecelerationAnimation(double scrollVelocity) {
  //   _scrollAnimationController?.stop();
  //   _scrollAnimationController?.dispose();
  //   _scrollAnimationController = null;
  //   if (scrollVelocity == 0) {
  //     return;
  //   }
  //   //0.2减速系数
  //   final distanceToScroll = scrollVelocity * 0.2;
  //   Duration duration = Duration(milliseconds: distanceToScroll.abs().toInt());
  //   _scrollAnimationController = AnimationController(vsync: this, duration: duration);
  //
  //   Animation<double> animation = Tween<double>(
  //     begin: _chartParam.offset.dx,
  //     end: _chartParam.offset.dx - distanceToScroll,
  //   ).animate(CurvedAnimation(
  //     parent: _scrollAnimationController!,
  //     curve: Curves.easeOutCubic,
  //   ));
  //
  //   animation.addListener(() {
  //     _chartParam.scroll(Offset(animation.value, 0));
  //   });
  //   _scrollAnimationController?.forward();
  // }

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

  void hitTest(Offset point) {
    List<ChartBodyRender> charts = widget.chartCoordinateRender.charts;
    //关联子状态
    for (int i = 0; i < charts.length; i++) {
      ChartBodyRender body = charts[i];
      //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
      ChartLayoutParam layoutParam = body.layout;
      layoutParam.selectedIndex = null;
      List<ChartItemLayoutParam> childrenLayoutParams = body.layout.children;
      for (int index = 0; index < childrenLayoutParams.length; index++) {
        ChartItemLayoutParam child = childrenLayoutParams[index];
        if (child.hitTest(point)) {
          layoutParam.selectedIndex = index;
          // debugPrint("选中了$index");
          break;
        }
      }
    }
  }
}

///画图
class _ChartPainter extends CustomPainter {
  final ChartCoordinateRender chart;
  final ChartsParam param;
  _ChartPainter({
    required this.chart,
    required this.param,
  }) : super(repaint: param);

  @override
  void paint(Canvas canvas, Size size) {
    chart.controller._bindParam(param);
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
    ChartsParam chartParam = oldDelegate.param;
    ChartsParam newChartParam = param;
    if (chartParam != newChartParam) {
      return true;
    }
    return false;
  }
}
