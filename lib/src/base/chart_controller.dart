import 'package:flutter/material.dart';

import 'chart_shape_state.dart';

typedef AnnotationTooltipWidgetRenderer = PreferredSizeWidget? Function(BuildContext context);

//数据共享，便于各个节点使用
class ChartController extends ChangeNotifier {
  Offset? _localPosition;

  //点击的位置信息
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

  void clear() {
    bool needNotify = false;
    if (tooltipContent != null) {
      tooltipContent = null;
      needNotify = true;
    }
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

  //自定义的内容 使用canvas渲染tooltip
  InlineSpan? tooltipContent;
  //目前即支持canvas画tooltip，也支持widget画，而canvas画自定义内容受限，所以后面不再使用该方法
  @Deprecated('即将废弃')
  void showTooltip({required InlineSpan content, required Offset position}) {
    tooltipContent = content;
    localPosition = position;
  }

  //使用widget渲染tooltip
  AnnotationTooltipWidgetRenderer? tooltipWidgetBuilder;
  void showTooltipBuilder({required AnnotationTooltipWidgetRenderer builder, required Offset position}) {
    tooltipWidgetBuilder = builder;
    localPosition = position;
    notifyTooltip();
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
