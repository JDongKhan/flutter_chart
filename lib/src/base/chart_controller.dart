part of flutter_chart_plus;

/// @author jd

///数据共享，便于各个节点使用
class ChartController {
  ///本次坐标系
  ChartCoordinateRender? _chartCoordinateRender;

  ///上一次的坐标系
  /// 用于做插值动画
  ChartCoordinateRender? _lastChartCoordinateRender;
  ChartCoordinateRender? get lastCoordinate => _lastChartCoordinateRender;

  ///通知弹框层刷新
  StateSetter? _tooltipStateSetter;

  ///chart 图形参数
  ChartsState? _state;

  ///根据位置缓存配置信息
  List<ChartLayoutState> get chartsStateList => _state?.chartsState ?? [];

  //外部设置的弹框位置，与点击的位置有区别
  Offset? _outLocation;
  Offset? get outLocation => _outLocation;
  Offset? get localPosition => _state?.layout.localPosition;

  ///重置提示框
  void resetTooltip() {
    bool needNotify = false;
    if (tooltipWidgetBuilder != null) {
      _tooltipWidgetBuilder = null;
      needNotify = true;
    }
    if (_outLocation != null) {
      _outLocation = null;
      needNotify = true;
    }
    if (_state?.layout.localPosition != null) {
      _state?.localPosition = null;
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
    _outLocation = position;
    _notifyTooltip();
  }

  void dispose() {
    _chartCoordinateRender = null;
    _lastChartCoordinateRender = null;
    _state = null;
    _tooltipStateSetter = null;
    _tooltipWidgetBuilder = null;
    _outLocation = null;
  }
}

///内部方法
extension _InnerFuncation on ChartController {
  void _attach(ChartCoordinateRender chartCoordinateRender) {
    chartCoordinateRender.controller = this;
    if (chartCoordinateRender.animationDuration != null) {
      _lastChartCoordinateRender = _chartCoordinateRender;
    }
    _chartCoordinateRender = chartCoordinateRender;
  }

  void _bindState(ChartsState p) {
    _state = p;
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
