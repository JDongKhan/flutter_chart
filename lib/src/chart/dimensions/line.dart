part of flutter_chart_plus;

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartBodyRender<T> {
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
  void init(ChartParam param) {
    super.init(param);
    //这里可以提前计算好数据
    if (filled == true) {
      _fullPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill;
    }
    if (param.animal) {
      //处理带动画的场景
      initWithAnimal(param);
    } else {
      //处理非动画的场景
      initWithoutAnimal(param);
    }
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    if (param.animal) {
      //绘制带动画的场景
      drawWithAnimal(canvas, param);
    } else {
      //绘制非带动画的场景
      drawWithOutAnimal(canvas, param);
    }
  }

  /******************************* 第一版 ******************************/
  void initWithAnimal(ChartParam param) {
    //异步初始化
    if (async) {
      Future.delayed(const Duration(microseconds: 0), () {
        return asyncInitWithAnimal();
      }).then((value) {
        param.needDraw();
      });
    } else {
      //少量数据为了体验好就不异步了
      asyncInitWithAnimal();
    }
  }

  Future asyncInitWithAnimal() async {
    layoutParam.children = [];
    num? lastXValue;
    int index = 0;
    ChartLayoutParam? lastShape;
    //先初始化模型数据
    for (T value in data) {
      ChartLayoutParam currentPointLayout = ChartLayoutParam();
      layoutParam.children.add(currentPointLayout);

      num xValue = position.call(value);
      if (lastXValue != null) {
        assert(lastXValue < xValue, '$xValue 必须大于 $lastXValue');
      }
      List<num>? yValues = currentPointLayout.yValues;
      yValues ??= values.call(value);

      //保存数据
      currentPointLayout.index = index;
      currentPointLayout.xValue = xValue;
      currentPointLayout.yValues = yValues;
      /******* 动画 *********/
      assert(colors.length >= yValues.length, '颜色配置跟数据源不匹配');
      assert(shaders == null || shaders!.length >= yValues.length, '颜色配置跟数据源不匹配');
      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        //计算点的位置
        num yValue = yValues[valueIndex];
        //点的信息
        ChartLayoutParam childLayoutParam = ChartLayoutParam();
        currentPointLayout.children.add(childLayoutParam);
        childLayoutParam.index = valueIndex;
        childLayoutParam.xValue = xValue;
        childLayoutParam.yValue = yValue;
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

  ///绘制
  void drawWithAnimal(Canvas canvas, ChartParam param) {
    param as _ChartDimensionParam;
    List<ChartLayoutParam> shapeList = layoutParam.children;
    List<ChartLayoutParam>? lastDataList = getLastData(param.animal);
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = param.layout.contentMargin.left;
    double right = param.layout.size.width - param.layout.contentMargin.right;
    double top = param.layout.contentMargin.top;
    double bottom = param.layout.size.height - param.layout.contentMargin.bottom;
    Map<int, LineInfo> pathMap = {};
    //遍历数据 处理数据信息
    for (int index = 0; index < shapeList.length; index++) {
      ChartLayoutParam currentPointLayout = shapeList[index];
      num xValue = currentPointLayout.xValue ?? 0;
      List<num> yValues = currentPointLayout.yValues ?? [];
      //是否有动画
      if (param.animal && param.layout.controlValue < 1) {
        List<num>? lastYValue;
        num? lastXValue;
        if (lastDataList != null && index < lastDataList.length) {
          ChartLayoutParam p = lastDataList[index];
          lastYValue = p.children.map((e) => e.yValue ?? 0).toList();
          lastXValue = p.xValue;
        }
        if (lastXValue != null) {
          //初始动画x轴不动
          xValue = ui.lerpDouble(lastXValue, xValue, param.layout.controlValue) ?? xValue;
        }
        yValues = lerpList(lastYValue, yValues, param.layout.controlValue) ?? yValues;
      }

      //计算x轴和y轴的物理位置  这里也会处理缩放
      double xPos = xValue * param.xAxis.density + left;
      xPos = param.layout.transform.withXOffset(xPos);

      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo(isCurve);
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num yValue = yValues[valueIndex];
        //y轴位置
        double yPos = bottom - param.yAxis[yAxisPosition].relativeHeight(yValue);
        yPos = param.layout.transform.withYOffset(yPos);
        Offset currentPoint = Offset(xPos, yPos);
        //数据过滤
        if (!param.outDraw && xPos < 0) {
          lineInfo.startPoint = currentPoint;
          lineInfo.pointList.add(currentPoint);
          // debugPrint('1-第${index + 1}个数据超出去');
          continue;
        }
        lineInfo.startPoint ??= currentPoint;

        //点的信息
        ChartLayoutParam childLayoutParam = currentPointLayout.children[valueIndex];
        childLayoutParam.setOriginRect(Rect.fromCenter(center: currentPoint, width: dotRadius, height: dotRadius));
        childLayoutParam.index = index;
        childLayoutParam.xValue = xValue;
        childLayoutParam.yValue = yValue;
        //存放点的位置
        lineInfo.appendPoint(childLayoutParam);
      }

      Rect currentRect = Rect.fromLTRB(xPos - dotRadius, top, xPos + dotRadius, bottom);
      currentPointLayout.setOriginRect(currentRect);
      currentPointLayout.left = left;
      currentPointLayout.right = right;
      //数据过滤
      if (!param.outDraw && xPos > param.layout.size.width) {
        // debugPrint('2-第$index个数据超出去');
        break;
      }
    }

    //开启后可查看热区是否正确
    // _showHotRect(canvas);
    //开始绘制了
    _drawLine(param, canvas, pathMap);
  }

  void _drawLine(ChartParam param, Canvas canvas, Map<int, LineInfo> pathMap) {
    //画线
    if (strokeWidth > 0 || filled == true) {
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
        if (strokeWidth > 0) {
          if (shaders != null && filled == false) {
            canvas.drawPath(path, _linePaint..shader = shaders![index]);
          } else {
            canvas.drawPath(path, _linePaint..color = colors[index]);
          }
        }

        //然后填充颜色
        if (filled == true) {
          Offset last = lineInfo.endPoint ?? Offset.zero;
          Offset first = lineInfo.startPoint ?? Offset.zero;
          path
            ..lineTo(last.dx, param.layout.contentRect.bottom)
            ..lineTo(first.dx, param.layout.contentRect.bottom);
          if (shaders != null) {
            _fullPaint?.shader = shaders![index];
          } else {
            _fullPaint?.color = colors[index];
          }
          Path newPath = lineInfo.path!;
          if (operation != null) {
            if (lastPath != null) {
              newPath = Path.combine(operation!, newPath, lastPath);
            }
            lastPath = lineInfo.path!;
          }
          canvas.drawPath(newPath, _fullPaint!);
        }
      }
    }
    //最后画点  防止被挡住
    // print(lineInfo.pointList);
    if (dotRadius > 0) {
      List<Color> dotColorList = dotColors ?? colors;
      for (int index in pathMap.keys) {
        LineInfo? lineInfo = pathMap[index];
        if (lineInfo == null) {
          continue;
        }
        for (Offset point in lineInfo.pointList) {
          if (!param.outDraw && point.dx < 0) {
            // debugPrint('1-第${lineInfo.pointList.indexOf(point) + 1} 个点 $point 超出去');
            continue;
          }
          if (!param.outDraw && point.dx > param.layout.size.width) {
            // debugPrint('2-第${lineInfo.pointList.indexOf(point) + 1} 个点 $point超出去');
            break;
          }
          //再画空心
          if (isHollow) {
            //先用白色覆盖
            _dotPaint.style = PaintingStyle.fill;
            canvas.drawCircle(point, dotRadius, _dotPaint..color = Colors.white);
            _dotPaint.style = PaintingStyle.stroke;
          } else {
            _dotPaint.style = PaintingStyle.fill;
          }
          canvas.drawCircle(point, dotRadius, _dotPaint..color = dotColorList[index]);
        }
      }
    }
  }
  /***************************************** 第一版结束 **************************/

  Map<int, LineInfo>? pathMap;
  void initWithoutAnimal(ChartParam param) {
    if (async) {
      Future.delayed(const Duration(microseconds: 0), () {
        return asyncInitWithOutAnimal(param);
      }).then((value) {
        pathMap = value;
        param.needDraw();
      });
    } else {
      pathMap = asyncInitWithOutAnimal(param);
    }
  }

  Map<int, LineInfo> asyncInitWithOutAnimal(ChartParam param) {
    param as _ChartDimensionParam;
    layoutParam.children = [];
    int index = 0;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = param.layout.contentMargin.left;
    double right = param.layout.size.width - param.layout.contentMargin.right;
    double top = param.layout.contentMargin.top;
    double bottom = param.layout.size.height - param.layout.contentMargin.bottom;
    Map<int, LineInfo> pathMap = {};
    ChartLayoutParam? lastShape;
    num? lastXValue;
    //遍历数据 处理数据信息
    for (T value in data) {
      ChartLineLayoutParam currentPointLayout = ChartLineLayoutParam();
      currentPointLayout.layout = param.layout;
      currentPointLayout.xAxis = param.xAxis;
      currentPointLayout.yAxis = param.yAxis;
      currentPointLayout.yAxisPosition = yAxisPosition;
      layoutParam.children.add(currentPointLayout);
      //获取原数据
      num? xValue = position.call(value);
      if (lastXValue != null) {
        assert(lastXValue < xValue, '$xValue 必须大于 $lastXValue,（虽然可以支持逆序，但是为了防止数据顺序混乱，还是强制要求必须是正序的数组)');
      }
      List<num>? yValues = currentPointLayout.yValues;
      yValues ??= values.call(value);

      //保存数据
      currentPointLayout.index = index;
      currentPointLayout.xValue = xValue;
      currentPointLayout.yValues = yValues;

      assert(colors.length >= yValues.length, '颜色配置跟数据源不匹配');
      assert(shaders == null || shaders!.length >= yValues.length, '颜色配置跟数据源不匹配');

      //计算x轴和y轴的物理位置
      double xPos = xValue * param.xAxis.density;
      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo(isCurve);
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num yValue = yValues[valueIndex];
        //y轴位置
        double yPos = bottom - param.yAxis[yAxisPosition].relativeHeight(yValue);
        Offset currentPoint = Offset(xPos, yPos);
        lineInfo.startPoint ??= currentPoint;

        //点的信息
        ChartLineLayoutParam childLayoutParam;
        if (valueIndex < currentPointLayout.children.length) {
          childLayoutParam = currentPointLayout.children[valueIndex] as ChartLineLayoutParam;
        } else {
          childLayoutParam = ChartLineLayoutParam();
          currentPointLayout.children.add(childLayoutParam);
        }

        childLayoutParam.setOriginRect(Rect.fromCenter(center: currentPoint, width: dotRadius, height: dotRadius));
        childLayoutParam.index = index;
        childLayoutParam.layout = param.layout;
        childLayoutParam.xAxis = param.xAxis;
        childLayoutParam.yAxis = param.yAxis;
        childLayoutParam.yAxisPosition = yAxisPosition;
        childLayoutParam.xValue = xValue;
        childLayoutParam.yValue = yValue;
        //存放点的位置
        lineInfo.appendPoint(childLayoutParam);
      }

      Rect currentRect = Rect.fromLTRB(xPos - dotRadius, top, xPos + dotRadius, bottom);
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

  void drawWithOutAnimal(Canvas canvas, ChartParam param) {
    //开始绘制了
    if (pathMap != null) {
      _drawLineWithOut(param, canvas, pathMap!);
    }
  }

  void _drawLineWithOut(ChartParam param, Canvas canvas, Map<int, LineInfo> pathMap) {
    param as _ChartDimensionParam;
    //画线
    if (strokeWidth > 0 || filled == true) {
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
        if (strokeWidth > 0) {
          final scaleMatrix = Matrix4.identity();
          scaleMatrix.translate(-(param.layout.offset.dx - param.layout.contentMargin.left), 0);
          double yScale = param.layout.controlValue;
          if (param.layout.zoom != 1 || param.animal) {
            scaleMatrix.scale(param.layout.zoom, yScale);
          }

          Path linePath = path.transform(scaleMatrix.storage);
          if (shaders != null && filled == false) {
            canvas.drawPath(linePath, _linePaint..shader = shaders![index]);
          } else {
            canvas.drawPath(linePath, _linePaint..color = colors[index]);
          }
        }

        //然后填充颜色
        if (filled == true) {
          Offset last = lineInfo.endPoint ?? Offset.zero;
          Offset first = lineInfo.startPoint ?? Offset.zero;
          path
            ..lineTo(last.dx, param.layout.contentRect.bottom)
            ..lineTo(first.dx, param.layout.contentRect.bottom);
          if (shaders != null) {
            _fullPaint?.shader = shaders![index];
          } else {
            _fullPaint?.color = colors[index];
          }
          Path newPath = lineInfo.path!;
          if (operation != null) {
            if (lastPath != null) {
              newPath = Path.combine(operation!, newPath, lastPath);
            }
            lastPath = lineInfo.path!;
          }
          final scaleMatrix = Matrix4.identity()..translate(-(param.layout.offset.dx - param.layout.contentMargin.left), 0);
          if (param.layout.zoom != 1) {
            scaleMatrix.scale(param.layout.zoom, 1);
          }
          Path filledPath = path.transform(scaleMatrix.storage);
          canvas.drawPath(filledPath, _fullPaint!);
        }
      }
    }
    //最后画点  防止被挡住
    // print(lineInfo.pointList);
    if (dotRadius > 0) {
      double top = param.layout.contentMargin.top;
      double bottom = param.layout.size.height - param.layout.contentMargin.bottom;
      double left = param.layout.contentMargin.left;
      List<Color> dotColorList = dotColors ?? colors;
      List<ChartLayoutParam> shapeList = layoutParam.children;
      for (ChartLayoutParam shape in shapeList) {
        List<ChartLayoutParam> children = shape.children;
        int childIndex = 0;
        double xPos = shape.xValue! * param.xAxis.density + left;
        xPos = param.layout.transform.withXOffset(xPos);

        Rect currentRect = Rect.fromLTRB(xPos - dotRadius, top, xPos + dotRadius, bottom);
        shape.setOriginRect(currentRect);
        if (!param.outDraw && xPos < 0) {
          // debugPrint('1-第${shape.index ?? 0 + 1} 个点$currentRect超出去 不需要处理');
          continue;
        }
        if (!param.outDraw && xPos > param.layout.size.width) {
          // debugPrint('2-第${shape.index ?? 0 + 1} 个点 $currentRect超出去 停止渲染');
          break;
        }

        for (ChartLayoutParam childLayoutParam in children) {
          double yPos = bottom - param.yAxis[yAxisPosition].relativeHeight(childLayoutParam.yValue!);
          Offset currentPoint = Offset(xPos, yPos);
          childLayoutParam.setOriginRect(Rect.fromCenter(center: currentPoint, width: dotRadius, height: dotRadius));
          //再画空心
          if (isHollow) {
            //先用白色覆盖
            _dotPaint.style = PaintingStyle.fill;
            canvas.drawCircle(currentPoint, dotRadius, _dotPaint..color = Colors.white);
            _dotPaint.style = PaintingStyle.stroke;
          } else {
            _dotPaint.style = PaintingStyle.fill;
          }
          canvas.drawCircle(currentPoint, dotRadius, _dotPaint..color = dotColorList[childIndex]);
          childIndex++;
        }
      }
    }

    //开启后可查看热区是否正确
    // _showHotRect(canvas);
  }

  ///开启后可查看热区是否正确
  void _showHotRect(Canvas canvas) {
    int i = 0;
    for (var element in layoutParam.children) {
      Rect? hotRect = element.getHotRect();
      print(hotRect);
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

  void appendPoint(ChartLayoutParam point) {
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
