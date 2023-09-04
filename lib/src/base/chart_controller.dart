import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';
import 'chart_param.dart';

/// @author jd

///数据共享，便于各个节点使用
class ChartController {
  ///
  WeakReference<ChartCoordinateRender>? _chartCoordinateRender;

  ///根据位置缓存配置信息
  late List<ChartShapeLayoutParam> allLayoutParams;

  Offset? tapPosition;

  Offset? get localPosition => _param?.localPosition;

  ///chart 图形参数
  ChartParam? _param;

  void attach(ChartCoordinateRender chartCoordinateRender) {
    chartCoordinateRender.controller = this;
    _chartCoordinateRender = WeakReference(chartCoordinateRender);
  }

  void detach() {
    _chartCoordinateRender = null;
  }

  void bindParam(ChartParam p) {
    _param = p;
  }

  ///重置提示框
  void resetTooltip() {
    bool needNotify = false;
    if (tooltipWidgetBuilder != null) {
      tooltipWidgetBuilder = null;
      needNotify = true;
    }
    if (tapPosition != null) {
      tapPosition = null;
      needNotify = true;
    }
    if (_param?.localPosition != null) {
      _param?.localPosition = null;
      needNotify = true;
    }
    if (needNotify) {
      notifyTooltip();
    }
  }

  AnnotationTooltipWidgetBuilder? tooltipWidgetBuilder;

  ///使用widget渲染tooltip
  void showTooltipBuilder({required AnnotationTooltipWidgetBuilder builder, required Offset position}) {
    tooltipWidgetBuilder = builder;
    tapPosition = position;
    notifyTooltip();
  }

  ///通知弹框层刷新
  StateSetter? tooltipStateSetter;
  void notifyTooltip() {
    if (tooltipStateSetter != null) {
      tooltipStateSetter?.call(() {});
    }
  }

  void reset() {
    _param?.reset();
  }
}
