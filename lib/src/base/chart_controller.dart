import 'package:flutter/material.dart';

import 'chart_shape_state.dart';

//数据共享，便于各个节点使用
class ChartController extends ChangeNotifier {
  Offset? _localPosition;

  set localPosition(value) {
    if (value != _localPosition) {
      _localPosition = value;
      notifyListeners();
    }
  }

  Offset? get localPosition => _localPosition;

  double _zoom = 1;
  //缩放
  double get zoom => _zoom;
  set zoom(v) {
    if (_zoom != v) {
      _zoom = v;
      notifyListeners();
    }
  }

  //偏移
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(v) {
    if (v != _offset) {
      _offset = v;
      notifyListeners();
    }
  }

  void refresh() {}

  void clearPosition() {
    if (localPosition != null) {
      localPosition = null;
      notifyTooltip();
    }
  }

  void notifyTooltip() {
    if (tooltipStateSetter != null) {
      Future.microtask(() {
        tooltipStateSetter?.call(() {});
      });
    }
  }

  StateSetter? tooltipStateSetter;

  //根据位置缓存配置信息
  List<CharBodyState> childrenState = [];
}

class CharBodyState {
  final ChartController parentController;
  CharBodyState(this.parentController);
  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;
  set selectedIndex(v) {
    _selectedIndex = v;
    // parentController.refresh();
  }

  List<ChartShapeState>? shapeList;
}
