import 'package:flutter/widgets.dart';

import 'chart_shape_state.dart';

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

class ChartParam extends ChangeNotifier {
  ///点击的位置
  Offset? _localPosition;
  Offset? get localPosition => _localPosition;

  ///点击的位置信息
  set localPosition(value) {
    if (value != _localPosition) {
      _localPosition = value;
      notifyListeners();
    }
  }

  ///缩放级别
  double _zoom = 1;
  double get zoom => _zoom;
  set zoom(v) {
    if (_zoom != v) {
      _zoom = v;
      notifyListeners();
    }
  }

  ///滚动偏移
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(v) {
    if (v != _offset) {
      _offset = v;
      notifyListeners();
    }
  }

  void reset() {
    zoom = 1.0;
    offset = Offset.zero;
    resetTooltip();
  }

  ///根据位置缓存配置信息
  List<CharBodyState> childrenState = [];

  ///通知弹框层刷新
  StateSetter? tooltipStateSetter;
  void notifyTooltip() {
    if (tooltipStateSetter != null) {
      Future.microtask(() {
        tooltipStateSetter?.call(() {});
      });
    }
  }

  ///重置提示框
  void resetTooltip() {
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

  AnnotationTooltipWidgetBuilder? tooltipWidgetBuilder;

  @override
  void dispose() {
    tooltipWidgetBuilder = null;
    _localPosition = null;
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
