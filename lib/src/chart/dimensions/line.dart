part of flutter_chart_plus;

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartBodyRender<T> with NormalLineMixin<T>, AnimalLineMixin<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///每个点对应的值 不要使用过于耗时的方法
  final LinePosition values;

  ///线颜色
  final List<Color> colors;

  ///优先级高于colors  跟filled有关，false是折线的颜色，true是填充色
  final List<Shader>? shaders;

  ///点的颜色
  final List<Color>? dotColors;

  ///点半径
  final double dotRadius;

  ///是否有空心圆
  final bool isHollow;

  ///线宽
  final double strokeWidth;

  ///是否填充颜色  true：填充，false：不填充  默认false
  final bool? filled;

  ///是否是曲线  默认false
  final bool isCurve;

  ///路径之间的处理规则
  final PathOperation? operation;

  ///是否异步初始化布局
  final bool async;

  Line({
    required super.data,
    required this.position,
    required this.values,
    super.yAxisPosition = 0,
    this.colors = colors10,
    this.shaders,
    this.dotColors,
    this.dotRadius = 2,
    this.strokeWidth = 1,
    this.isHollow = false,
    this.filled = false,
    this.isCurve = false,
    this.operation,
    this.async = false,
  });

  ///线 画笔
  late final Paint _linePaint = Paint()
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  ///点的画笔
  late final Paint _dotPaint = Paint()..strokeWidth = strokeWidth;

  ///填充物画笔
  Paint? _fullPaint;

  @override
  void init(ChartsState state) {
    _instance = this;
    super.init(state);
    //这里可以提前计算好数据
    if (filled == true) {
      _fullPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill;
    }
  }

  ///合并path
  Path _combinePath(Path path, Offset first, Offset last, Path? lastPath) {
    path
      ..lineTo(last.dx, last.dy)
      ..lineTo(first.dx, first.dy);
    Path newPath = path;
    if (operation != null) {
      if (lastPath != null) {
        newPath = Path.combine(operation!, newPath, lastPath);
      }
    }
    return newPath;
  }

  ///画线
  void _drawLine(Canvas canvas, Path path, int index) {
    if (shaders != null && filled == false) {
      canvas.drawPath(path, _linePaint..shader = shaders![index]);
    } else {
      canvas.drawPath(path, _linePaint..color = colors[index]);
    }
  }

  void _drawFill(Canvas canvas, Path path, int index) {
    if (shaders != null) {
      _fullPaint?.shader = shaders![index];
    } else {
      _fullPaint?.color = colors[index];
    }
    canvas.drawPath(path, _fullPaint!);
  }

  ///画点
  void _drawPoint(Canvas canvas, Offset point, Color color) {
    //再画空心
    if (isHollow) {
      //先用白色覆盖
      _dotPaint.style = PaintingStyle.fill;
      canvas.drawCircle(point, dotRadius, _dotPaint..color = Colors.white);
      _dotPaint.style = PaintingStyle.stroke;
    } else {
      _dotPaint.style = PaintingStyle.fill;
    }
    canvas.drawCircle(point, dotRadius, _dotPaint..color = color);
  }

  ///开启后可查看热区是否正确
  void _showHotRect(Canvas canvas) {
    int i = 0;
    for (var element in chartState.children) {
      Rect? hotRect = element.getHotRect();
      // print(hotRect);
      if (hotRect != null) {
        Rect newRect = Rect.fromLTRB(hotRect.left + 1, hotRect.top + 1, hotRect.right - 1, hotRect.bottom);
        Paint newPaint = Paint()
          ..color = colors10[i % colors10.length]
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawRect(newRect, newPaint);
      }
      i++;
    }
  }
}

///正常模式下绘图操作  基于path做transform变换，但是不好做差值动画
mixin NormalLineMixin<T> on ChartBodyRender<T> {
  Map<int, LineInfo>? _pathMap;

  late Line<T> _instance;

  @override
  void init(ChartsState state) {
    super.init(state);
    if (!state.animal) {
      _initWithoutAnimal(state);
    }
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    super.draw(canvas, state);
    if (!state.animal) {
      _drawWithOutAnimal(canvas, state);
    }
  }

  void _initWithoutAnimal(ChartsState state) {
    if (_instance.async) {
      Future.delayed(const Duration(microseconds: 0), () {
        return asyncInitWithOutAnimal(state);
      }).then((value) {
        _pathMap = value;
        state.setNeedsDraw();
      });
    } else {
      _pathMap = asyncInitWithOutAnimal(state);
    }
  }

  Map<int, LineInfo> asyncInitWithOutAnimal(ChartsState state) {
    ChartDimensionCoordinateState layout = state.layout as ChartDimensionCoordinateState;
    chartState.children = [];
    int index = 0;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = layout.left;
    double right = layout.right;
    double top = layout.top;
    double bottom = layout.bottom;
    Map<int, LineInfo> pathMap = {};
    ChartItemLayoutState? lastShape;
    num? lastXValue;
    //遍历数据 处理数据信息
    for (T value in data) {
      ChartLineLayoutState currentPointLayout = ChartLineLayoutState();
      currentPointLayout.layout = layout;
      currentPointLayout.xAxis = layout.xAxis;
      currentPointLayout.yAxis = layout.yAxis;
      currentPointLayout.yAxisPosition = yAxisPosition;
      chartState.children.add(currentPointLayout);
      //获取原数据
      num? xValue = _instance.position.call(value);
      if (lastXValue != null) {
        assert(lastXValue < xValue, '$xValue 必须大于 $lastXValue,（虽然可以支持逆序，但是为了防止数据顺序混乱，还是强制要求必须是正序的数组)');
      }
      List<num>? yValues = currentPointLayout.yValues;
      yValues ??= _instance.values.call(value);

      //保存数据
      currentPointLayout.index = index;
      currentPointLayout.xValue = xValue;
      currentPointLayout.yValues = yValues;

      assert(_instance.colors.length >= yValues.length, '颜色配置跟数据源不匹配');
      assert(_instance.shaders == null || _instance.shaders!.length >= yValues.length, '颜色配置跟数据源不匹配');

      //计算x轴和y轴的物理位置
      double xPos = xValue * layout.xAxis.density;
      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo(_instance.isCurve);
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num yValue = yValues[valueIndex];
        //y轴位置
        double yPos = bottom - layout.yAxis[yAxisPosition].getItemHeight(yValue);
        Offset currentPoint = Offset(xPos, yPos);
        lineInfo.startPoint ??= currentPoint;

        //点的信息
        ChartLineLayoutState childLayoutState;
        if (valueIndex < currentPointLayout.children.length) {
          childLayoutState = currentPointLayout.children[valueIndex] as ChartLineLayoutState;
        } else {
          childLayoutState = ChartLineLayoutState();
          currentPointLayout.children.add(childLayoutState);
        }

        childLayoutState.setOriginRect(Rect.fromCenter(center: currentPoint, width: _instance.dotRadius, height: _instance.dotRadius));
        childLayoutState.index = index;
        childLayoutState.layout = layout;
        childLayoutState.xAxis = layout.xAxis;
        childLayoutState.yAxis = layout.yAxis;
        childLayoutState.yAxisPosition = yAxisPosition;
        childLayoutState.xValue = xValue;
        childLayoutState.yValue = yValue;
        //存放点的位置
        lineInfo.appendPoint(childLayoutState);
      }

      Rect currentRect = Rect.fromLTRB(xPos - _instance.dotRadius, top, xPos + _instance.dotRadius, bottom);
      currentPointLayout.setOriginRect(currentRect);
      currentPointLayout.left = left;
      currentPointLayout.right = right;
      //这里用链表解决查找附近节点的问题
      currentPointLayout.preShapeState = lastShape;
      lastShape?.nextShapeState = currentPointLayout;
      lastShape = currentPointLayout;
      //放到最后
      index++;
      lastXValue = xValue;
    }
    return pathMap;
  }

  void _drawWithOutAnimal(Canvas canvas, ChartsState state) {
    //开始绘制了
    if (_pathMap != null) {
      _drawLineWithOut(state, canvas, _pathMap!);
    }
  }

  void _drawLineWithOut(ChartsState state, Canvas canvas, Map<int, LineInfo> pathMap) {
    ChartDimensionCoordinateState layout = state.layout as ChartDimensionCoordinateState;
    //画线
    if (_instance.strokeWidth > 0 || _instance.filled == true) {
      Path? lastPath;
      for (int index in pathMap.keys) {
        LineInfo? lineInfo = pathMap[index];
        if (lineInfo == null || lineInfo.pointList.isEmpty) {
          continue;
        }
        Path? path = lineInfo.path;
        if (path == null) {
          continue;
        }
        //先画线
        if (_instance.strokeWidth > 0) {
          final scaleMatrix = Matrix4.identity();
          scaleMatrix.translate(-(layout.offset.dx - layout.left), 0);
          double yScale = layout.controlValue;
          if (layout.zoom != 1 || state.animal) {
            scaleMatrix.scale(layout.zoom, yScale);
          }
          Path linePath = path.transform(scaleMatrix.storage);
          //画线
          _instance._drawLine(canvas, linePath, index);
        }

        //然后填充颜色
        if (_instance.filled == true) {
          Path copyPath = path.shift(Offset.zero);
          Offset last = lineInfo.endPoint ?? Offset.zero;
          Offset first = lineInfo.startPoint ?? Offset.zero;

          //路径合并
          Path filledPath = _instance._combinePath(copyPath, Offset(first.dx, layout.bottom), Offset(last.dx, layout.bottom), lastPath);
          lastPath = copyPath;

          //缩放，滚动
          final scaleMatrix = Matrix4.identity();
          scaleMatrix.translate(-(layout.offset.dx - layout.left), 0);
          if (layout.zoom != 1) {
            scaleMatrix.scale(layout.zoom, 1);
          }
          filledPath = filledPath.transform(scaleMatrix.storage);
          //画填充
          _instance._drawFill(canvas, filledPath, index);
        }
      }
    }
    //最后画点  防止被挡住
    // print(lineInfo.pointList);
    if (_instance.dotRadius > 0) {
      List<Color> dotColorList = _instance.dotColors ?? _instance.colors;
      List<ChartItemLayoutState> shapeList = chartState.children;
      for (ChartItemLayoutState shape in shapeList) {
        List<ChartItemLayoutState> children = shape.children;
        int childIndex = 0;
        double xPos = layout.getPosForX(shape.xValue! * layout.xAxis.density, true);
        Rect currentRect = Rect.fromLTRB(xPos - _instance.dotRadius, layout.top, xPos + _instance.dotRadius, layout.bottom);
        shape.setOriginRect(currentRect);
        if (!state.outDraw && xPos < 0) {
          // debugPrint('1-第${shape.index ?? 0 + 1} 个点$currentRect超出去 不需要处理');
          continue;
        }
        if (!state.outDraw && xPos > layout.size.width) {
          // debugPrint('2-第${shape.index ?? 0 + 1} 个点 $currentRect超出去 停止处理');
          break;
        }
        for (ChartItemLayoutState childLayoutState in children) {
          double yPos = layout.getPosForY(layout.yAxis[yAxisPosition].getItemHeight(childLayoutState.yValue!));
          Offset currentPoint = Offset(xPos, yPos);
          childLayoutState.setOriginRect(Rect.fromCenter(center: currentPoint, width: _instance.dotRadius, height: _instance.dotRadius));
          //画点
          _instance._drawPoint(canvas, currentPoint, dotColorList[childIndex]);
          childIndex++;
        }
      }
    }

    //开启后可查看热区是否正确
    // line._showHotRect(canvas);
  }
}

/// 基于元数据做tween动画， 如果基于path，不太好做数据差值处理
mixin AnimalLineMixin<T> on ChartBodyRender<T> {
  late Line<T> _instance;
  @override
  void init(ChartsState state) {
    super.init(state);
    if (state.animal) {
      //处理带动画的场景
      _initWithAnimal(state);
    }
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    super.draw(canvas, state);
    if (state.animal) {
      _drawWithAnimal(canvas, state);
    }
  }

  void _initWithAnimal(ChartsState state) {
    //异步初始化
    if (_instance.async) {
      Future.delayed(const Duration(microseconds: 0), () {
        return _asyncInitWithAnimal();
      }).then((value) {
        state.setNeedsDraw();
      });
    } else {
      //少量数据为了体验好就不异步了
      _asyncInitWithAnimal();
    }
  }

  void _asyncInitWithAnimal() {
    chartState.children = [];
    num? lastXValue;
    int index = 0;
    ChartItemLayoutState? lastShape;
    //先初始化模型数据
    for (T value in data) {
      ChartItemLayoutState currentPointLayout = ChartItemLayoutState();
      chartState.children.add(currentPointLayout);

      //获取原始值
      num xValue = _instance.position.call(value);
      if (lastXValue != null) {
        assert(lastXValue < xValue, '$xValue 必须大于 $lastXValue');
      }
      List<num>? yValues = currentPointLayout.yValues;
      yValues ??= _instance.values.call(value);

      //保存数据
      currentPointLayout.index = index;
      currentPointLayout.xValue = xValue;
      currentPointLayout.yValues = yValues;
      /******* 动画 *********/
      assert(_instance.colors.length >= yValues.length, '颜色配置跟数据源不匹配');
      assert(_instance.shaders == null || _instance.shaders!.length >= yValues.length, '颜色配置跟数据源不匹配');
      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        //计算点的位置
        num yValue = yValues[valueIndex];
        //点的信息
        ChartItemLayoutState childLayoutState = ChartItemLayoutState();
        currentPointLayout.children.add(childLayoutState);
        childLayoutState.index = valueIndex;
        childLayoutState.xValue = xValue;
        childLayoutState.yValue = yValue;
      }
      //这里用链表解决查找附近节点的问题
      currentPointLayout.preShapeState = lastShape;
      lastShape?.nextShapeState = currentPointLayout;
      lastShape = currentPointLayout;
      //放到最后
      index++;
      lastXValue = xValue;
    }
  }

  /// 绘制 此方法非动画也可以用，跟下面的区别是 此处draw时滚动/缩放操作后会根据原始值重新计算位置 如果存在动画体验较好，性能有待观察，所以就先在动画的场景使用。
  /// 而最下面的实现方式是预先生成path，后续的滚动缩放操作根据path再处理
  void _drawWithAnimal(Canvas canvas, ChartsState state) {
    ChartDimensionCoordinateState layout = state.layout as ChartDimensionCoordinateState;
    List<ChartItemLayoutState> shapeList = chartState.children;
    List<ChartItemLayoutState>? lastDataList = getLastData(state.animal && layout.controlValue < 1);
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    Map<int, LineInfo> pathMap = {};
    //遍历数据 处理数据信息
    for (int index = 0; index < shapeList.length; index++) {
      ChartItemLayoutState currentPointLayout = shapeList[index];
      num xValue = currentPointLayout.xValue ?? 0;
      List<num> yValues = currentPointLayout.yValues ?? [];
      //是否有动画
      if (state.animal && layout.controlValue < 1) {
        List<num>? lastYValue;
        num? lastXValue;
        if (lastDataList != null && index < lastDataList.length) {
          ChartItemLayoutState p = lastDataList[index];
          lastYValue = p.children.map((e) => e.yValue ?? 0).toList();
          lastXValue = p.xValue;
        }
        if (lastXValue != null) {
          //初始动画x轴不动
          xValue = ui.lerpDouble(lastXValue, xValue, layout.controlValue) ?? xValue;
        }
        yValues = lerpList(lastYValue, yValues, layout.controlValue) ?? yValues;
      }

      //计算x轴和y轴的物理位置  这里也会处理缩放
      double xPos = layout.getPosForX(xValue * layout.xAxis.density);

      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo(_instance.isCurve);
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num yValue = yValues[valueIndex];
        //y轴位置
        double yPos = layout.getPosForY(layout.yAxis[yAxisPosition].getItemHeight(yValue));
        yPos = layout.transform.withYScroll(yPos);
        Offset currentPoint = Offset(xPos, yPos);
        //数据过滤
        if (!state.outDraw && xPos < 0) {
          lineInfo.startPoint = currentPoint;
          lineInfo.pointList.add(currentPoint);
          // debugPrint('1-第${index + 1}个数据超出去');
          continue;
        }
        lineInfo.startPoint ??= currentPoint;

        //点的信息
        ChartItemLayoutState childLayoutState = currentPointLayout.children[valueIndex];
        childLayoutState.setOriginRect(Rect.fromCenter(center: currentPoint, width: _instance.dotRadius, height: _instance.dotRadius));
        childLayoutState.index = index;
        childLayoutState.xValue = xValue;
        childLayoutState.yValue = yValue;
        //存放点的位置
        lineInfo.appendPoint(childLayoutState);
      }

      Rect currentRect = Rect.fromLTRB(xPos - _instance.dotRadius, layout.top, xPos + _instance.dotRadius, layout.bottom);
      currentPointLayout.setOriginRect(currentRect);
      currentPointLayout.left = layout.left;
      currentPointLayout.right = layout.right;
      //数据过滤
      if (!state.outDraw && xPos > layout.size.width) {
        // debugPrint('2-第$index个数据超出去');
        break;
      }
    }

    //开启后可查看热区是否正确
    //  line._showHotRect(canvas);
    //开始绘制了
    _drawLineWithAnimal(state, canvas, pathMap);
  }

  void _drawLineWithAnimal(ChartsState state, Canvas canvas, Map<int, LineInfo> pathMap) {
    //画线
    if (_instance.strokeWidth > 0 || _instance.filled == true) {
      Path? lastPath;
      for (int index in pathMap.keys) {
        LineInfo? lineInfo = pathMap[index];
        if (lineInfo == null || lineInfo.pointList.isEmpty) {
          continue;
        }
        Path? path = lineInfo.path;
        if (path == null) {
          continue;
        }
        //先画线
        if (_instance.strokeWidth > 0) {
          _instance._drawLine(canvas, path, index);
        }
        //然后填充颜色
        if (_instance.filled == true) {
          Offset last = lineInfo.endPoint ?? Offset.zero;
          Offset first = lineInfo.startPoint ?? Offset.zero;

          //路径合并
          Path filledPath = _instance._combinePath(path, Offset(first.dx, state.layout.bottom), Offset(last.dx, state.layout.bottom), lastPath);
          lastPath = path;

          //绘制填充
          _instance._drawFill(canvas, filledPath, index);
        }
      }
    }
    //最后画点  防止被挡住
    // print(lineInfo.pointList);
    if (_instance.dotRadius > 0) {
      List<Color> dotColorList = _instance.dotColors ?? _instance.colors;
      for (int index in pathMap.keys) {
        LineInfo? lineInfo = pathMap[index];
        if (lineInfo == null) {
          continue;
        }
        for (Offset point in lineInfo.pointList) {
          if (!state.outDraw && point.dx < 0) {
            // debugPrint('1-第${lineInfo.pointList.indexOf(point) + 1} 个点 $point 超出去');
            continue;
          }
          if (!state.outDraw && point.dx > state.layout.size.width) {
            // debugPrint('2-第${lineInfo.pointList.indexOf(point) + 1} 个点 $point超出去');
            break;
          }
          //画点
          _instance._drawPoint(canvas, point, dotColorList[index]);
        }
      }
    }
  }
}

class LineInfo {
  ///起点
  Offset? _startPoint;
  Offset? get startPoint => _startPoint;
  set startPoint(v) {
    _startPoint = v;
    _path = Path();
    _path?.moveTo(v.dx, v.dy);
  }

  ///结束点
  Offset? _endPoint;
  Offset? get endPoint => _endPoint;

  ///曲线
  final bool isCurve;

  ///line path
  Path? _path;

  ///曲线
  Path? _curvePath;

  ///point 列表
  final List<Offset> _pointList = [];
  List<Offset> get pointList => _pointList;

  ///曲线
  Path? get curvePath {
    if (_curvePath != null) {
      return _curvePath;
    }
    _curvePath = Path();
    _curvePath?.moveTo(_startPoint!.dx, _startPoint!.dy);
    MonotoneX.addCurve(_curvePath!, _pointList);
    return _curvePath;
  }

  //path
  Path? get path {
    if (isCurve) {
      return curvePath;
    }
    if (_path == null) {
      return null;
    }
    return _path;
  }

  void appendPoint(ChartItemLayoutState point) {
    Offset currentPoint = point.originRect!.center;
    _endPoint = currentPoint;
    //非曲线就先append到path中
    if (!isCurve) {
      _path?.lineTo(currentPoint.dx, currentPoint.dy);
    }
    _pointList.add(Offset(currentPoint.dx, currentPoint.dy));
  }

  LineInfo(this.isCurve);
}
