part of flutter_chart_plus;

/// @author jd

///数据共享，便于各个节点使用
class ChartController {
  ///
  ChartCoordinateRender? _chartCoordinateRender;
  //上一次的坐标信息 用于做插值动画
  ChartCoordinateRender? _lastChartCoordinateRender;
  ChartCoordinateRender? get lastCoordinate => _lastChartCoordinateRender;

  ///通知弹框层刷新
  StateSetter? _tooltipStateSetter;

  ///chart 图形参数
  ChartsParam? _param;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> get chartParam => _param?.childrenState ?? [];

  Offset? _outTapLocation;
  Offset? get outTapLocation => _outTapLocation;
  Offset? get localPosition => _param?.layout.localPosition;

  ///重置提示框
  void resetTooltip() {
    bool needNotify = false;
    if (tooltipWidgetBuilder != null) {
      _tooltipWidgetBuilder = null;
      needNotify = true;
    }
    if (_outTapLocation != null) {
      _outTapLocation = null;
      needNotify = true;
    }
    if (_param?.layout.localPosition != null) {
      _param?.localPosition = null;
      needNotify = true;
    }
    if (needNotify) {
      _notifyTooltip();
    }
  }

  AnnotationTooltipWidgetBuilder? _tooltipWidgetBuilder;
  get tooltipWidgetBuilder => _tooltipWidgetBuilder;

  ///使用widget渲染tooltip
  void showTooltipBuilder({required AnnotationTooltipWidgetBuilder builder, required Offset position}) {
    _tooltipWidgetBuilder = builder;
    _outTapLocation = position;
    _notifyTooltip();
  }

  void dispose() {
    _chartCoordinateRender = null;
    _lastChartCoordinateRender = null;
    _param = null;
    _tooltipStateSetter = null;
    _tooltipWidgetBuilder = null;
    _outTapLocation = null;
  }
}

extension _InnerFuncation on ChartController {
  void _attach(ChartCoordinateRender chartCoordinateRender) {
    chartCoordinateRender.controller = this;
    if (chartCoordinateRender.animationDuration != null) {
      _lastChartCoordinateRender = _chartCoordinateRender;
    }
    _chartCoordinateRender = chartCoordinateRender;
  }

  void _bindParam(ChartsParam p) {
    _param = p;
  }

  void _bindTooltipStateSetter(StateSetter? stateSetter) {
    _tooltipStateSetter = stateSetter;
  }

  void _notifyTooltip() {
    if (_tooltipStateSetter != null) {
      _tooltipStateSetter?.call(() {});
    }
  }
}
