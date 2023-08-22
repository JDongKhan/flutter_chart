import 'package:flutter/material.dart';

import 'chart_shape_state.dart';

/// @author jd

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

///数据共享，便于各个节点使用
class ChartController extends ChangeNotifier {
  Offset? _localPosition;

  ///点击的位置信息
  set localPosition(value) {
    if (value != _localPosition) {
      _localPosition = value;
      notifyListeners();
    }
  }

  Offset? get localPosition => _localPosition;

  double _zoom = 1;

  ///缩放级别
  double get zoom => _zoom;
  set zoom(v) {
    if (_zoom != v) {
      _zoom = v;
      notifyListeners();
    }
  }

  ///偏移
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(v) {
    if (v != _offset) {
      _offset = v;
      notifyListeners();
    }
  }

  ///清理信息
  void clear() {
    bool needNotify = false;
    if (tooltipWidgetBuilder != null) {
      tooltipWidgetBuilder = null;
      needNotify = true;
    }
    if (localPosition != null) {
      localPosition = null;
      needNotify = true;
    }
    if (needNotify) {
      notifyTooltip();
    }
  }

  ///使用widget渲染tooltip
  AnnotationTooltipWidgetBuilder? tooltipWidgetBuilder;
  void showTooltipBuilder({required AnnotationTooltipWidgetBuilder builder, required Offset position}) {
    tooltipWidgetBuilder = builder;
    localPosition = position;
    notifyTooltip();
  }

  StateSetter? tooltipStateSetter;

  ///通知弹框层刷新
  void notifyTooltip() {
    if (tooltipStateSetter != null) {
      Future.microtask(() {
        tooltipStateSetter?.call(() {});
      });
    }
  }

  ///根据位置缓存配置信息
  List<CharBodyState> childrenState = [];

  @override
  void dispose() {
    _localPosition = null;
    tooltipStateSetter = null;
    tooltipWidgetBuilder = null;
    childrenState.clear();
    super.dispose();
  }
}

///每块图表存放的状态
class CharBodyState {
  CharBodyState();
  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;
  set selectedIndex(v) {
    _selectedIndex = v;
  }

  ///图形列表
  List<ChartShapeState>? shapeList;
}
