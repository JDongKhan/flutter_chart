import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'chart_shape_state.dart';

//数据共享，便于各个节点使用
class ChartController extends ChangeNotifier {
  Offset? _gesturePoint;
  set gesturePoint(value) {
    if (value != _gesturePoint) {
      _gesturePoint = value;
    }
  }

  Offset? get gesturePoint => _gesturePoint;

  double _zoom = 1;
  //缩放
  double get zoom => _zoom;
  set zoom(v) {
    gesturePoint = null;
    _zoom = v;
  }

  //偏移
  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(v) {
    gesturePoint = null;
    _offset = v;
  }

  void refresh() {
    notifyListeners();
  }

  //根据位置缓存配置信息
  Map<int, CharBodyController> childrenController = {};
}

class CharBodyController {
  final ChartController parentController;
  CharBodyController(this.parentController);
  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;
  set selectedIndex(v) {
    _selectedIndex = v;
    if (v != null) {
      parentController.refresh();
    }
  }

  List<ChartShapeState>? shapeList;
}
