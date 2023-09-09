import 'package:flutter/widgets.dart';

import '../coordinate/chart_circular_coordinate_render.dart';
import '../coordinate/chart_coordinate_render.dart';
import '../coordinate/chart_dimensions_coordinate_render.dart';
import 'chart_layout_param.dart';
import '../utils/transform_utils.dart';
import 'chart_circular_param.dart';
import 'chart_dimension_param.dart';

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

abstract class ChartParam extends ChangeNotifier {
  ///控制点
  final double controlValue;

  ///点击的位置
  Offset? _localPosition;
  set localPosition(v) {
    if (v != _localPosition) {
      _localPosition = v;
      notifyListeners();
    }
  }

  get localPosition => _localPosition;

  ///缩放级别
  double _zoom = 1;
  set zoom(v) {
    if (v != _zoom) {
      _zoom = v;
      notifyListeners();
    }
  }

  get zoom => _zoom;

  ///滚动偏移
  Offset _offset = Offset.zero;
  set offset(v) {
    if (v != _offset) {
      _offset = v;
      notifyListeners();
    }
  }

  get offset => _offset;

  ///不在屏幕内是否绘制 默认不绘制
  final bool outDraw;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> childrenState = [];

  ///获取所在位置的布局信息
  ChartLayoutParam paramAt(index) => childrenState[index];

  ChartParam({
    this.outDraw = false,
    this.controlValue = 1,
    required this.childrenState,
  });

  factory ChartParam.coordinate({
    bool outDraw = false,
    double controlValue = 1,
    required List<ChartLayoutParam> childrenState,
    required ChartCoordinateRender coordinate,
  }) {
    if (coordinate is ChartDimensionsCoordinateRender) {
      return ChartDimensionParam.coordinate(
        outDraw: outDraw,
        childrenState: childrenState,
        coordinate: coordinate,
        controlValue: controlValue,
      );
    }
    return ChartCircularParam.coordinate(
      outDraw: outDraw,
      childrenState: childrenState,
      coordinate: coordinate as ChartCircularCoordinateRender,
      controlValue: controlValue,
    );
  }

  ///坐标转换工具
  late TransformUtils transformUtils;

  late Size size;
  late EdgeInsets margin;
  late EdgeInsets padding;

  Size get contentSize => contentRect.size;

  ///图形内容的外边距信息
  late EdgeInsets contentMargin;

  ///未处理的坐标  原点在左上角
  Rect get contentRect => Rect.fromLTRB(contentMargin.left, contentMargin.top, size.width - contentMargin.left, size.height - contentMargin.bottom);

  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    this.size = size;
    this.margin = margin;
    this.padding = padding;
    contentMargin = EdgeInsets.fromLTRB(margin.left + padding.left, margin.top + padding.top, margin.right + padding.right, margin.bottom + padding.bottom);
  }

  void scroll(Offset offset);

  void scale(double zoom) {}

  @override
  bool operator ==(Object other) {
    if (other is ChartParam) {
      return super == other && zoom == other.zoom && localPosition == other.localPosition && offset == other.offset;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _zoom, _offset, _localPosition);
}
