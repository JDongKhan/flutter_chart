part of flutter_chart_plus;

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

abstract class ChartsState extends ChangeNotifier {
  ///布局信息
  late ChartCoordinateParam _layout;
  ChartCoordinateParam get layout => _layout;

  set localPosition(v) {
    if (v != _layout.localPosition) {
      _layout.localPosition = v;
      notifyListeners();
    }
  }

  set zoom(v) {
    if (v != _layout.zoom) {
      _layout.zoom = v;
      notifyListeners();
    }
  }

  set offset(v) {
    if (v != _layout.offset) {
      _layout.offset = v;
      notifyListeners();
    }
  }

  ///不在屏幕内是否绘制 默认不绘制
  final bool outDraw;

  ///是否动画
  late bool animal;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> chartsState = [];

  ///获取所在位置的布局信息
  ChartLayoutParam paramAt(index) => chartsState[index];

  ChartsState({
    this.outDraw = false,
    required this.chartsState,
  });

  factory ChartsState.coordinate({
    bool outDraw = false,
    double controlValue = 1,
    required Size size,
    required EdgeInsets margin,
    required EdgeInsets padding,
    required List<ChartLayoutParam> chartsState,
    required ChartCoordinateRender coordinate,
  }) {
    if (coordinate is ChartDimensionsCoordinateRender) {
      return _ChartDimensionState.coordinate(
        size: size,
        margin: margin,
        padding: padding,
        outDraw: outDraw,
        chartsState: chartsState,
        coordinate: coordinate,
        controlValue: controlValue,
      )..animal = coordinate.animationDuration != null;
    }
    return _ChartCircularState.coordinate(
      size: size,
      margin: margin,
      padding: padding,
      outDraw: outDraw,
      chartsState: chartsState,
      coordinate: coordinate as ChartCircularCoordinateRender,
      controlValue: controlValue,
    )..animal = coordinate.animationDuration != null;
  }

  void init();

  void scrollByDelta(Offset delta);

  void scroll(Offset offset);

  @override
  bool operator ==(Object other) {
    if (other is ChartsState) {
      return super == other && _layout.zoom == other._layout.zoom && _layout.localPosition == other._layout.localPosition && _layout.offset == other._layout.offset;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _layout.zoom, _layout.offset, _layout.localPosition);

  ///刷新布局
  void setNeedsDraw() {
    notifyListeners();
  }
}
