
## Flutter_chart

这是一款轻量级的flutter版本chart组件，目前已支持LineChart、BarChart、PieChart。

该组件支持缩放、水平滚动、选中变色、自定义标注等功能，并且使用很简单，代码量极少，可扩展性极强。

### 为何自己造轮子？
市面上有很多种chart，经过长时间的调研，发现没有一款完成符合自己需求的组件，有的样式太过个性化比如fl_chart，有的功能太简单，找了许久感觉graphic最合适，但是在项目使用过程中发现一些bug，也和作者沟通过，或许有其他计划响应不及时造就了项目出现风险。
而这个库对标的是echart，概念也较新，作者最近更新频率又较低，所有目前来看路还很长，所以就有了这个项目。
还有一点是一些组件为了设计可能对数据各种遍历，当数据量大的时候会有性能瓶颈问题，比如graphic只支持一个数组，那么像一个数组要画多条线时需要自己来循环磨平，再加上框架各种计算数组会循环很多遍。

当然自己造了个轮子也不是什么都支持的，所以首要目的是满足基本功能之余代码尽可能精简、独立，让使用者可以二次开发或者在之前的基础上容易扩展，最主要的是本组件支持数组内画多条图形，而仅仅一次遍历就可以了。


本项目是基于坐标系+图形两种概念实现，提供了两个坐标系：DimensionsChartCoordinateRender二维坐标系和CircularChartCoordinateRender圆形坐标系 + 各种对应的图形render + 各种annotation，这三个各种组合基本可以满足绝大部分场景。

当然了，如果满足不了你的需求，你可以重写ChartRender自己绘制，如果是需要增强能力则可以通过增加Annotation（在example中有使用，可以查看如何使用），甚至可以自定义Annotation。


![demo png](1.gif "demo")
![demo png](2.gif "demo")
![demo png](3.gif "demo")

![demo png](1.png "demo")
![demo png](2.png "demo")
![demo png](3.png "demo")

BarChart:
```dart

SizedBox(
height: 200,
child: ChartWidget(
  builder: () => LineBarChartCoordinateRender(
    yAxis: [
      YAxis(
        min: 0,
        max: 500,
      )
    ],
    margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
    xAxis: XAxis(
      count: 7,
      max: 30,
      formatter: (index) {
        return startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd');
      },
    ),
    charts: [
      StackBar(
        data: dataList,
        position: (item) {
          return parserDateTimeToDayValue(item['time'] as DateTime, startTime);
        },
        direction: Axis.horizontal,
        itemWidth: 10,
        highlightColor: Colors.yellow,
        values: (item) => [
          double.parse(item['value1'].toString()),
          double.parse(item['value2'].toString()),
          double.parse(item['value3'].toString()),
        ],
      ),
    ],
  ),
),
)  

```

LineChart

```dart
       
 SizedBox(
// color: Colors.yellow,
height: 200,
child: ChartWidget(
  builder: () => LineBarChartCoordinateRender(
    margin: const EdgeInsets.only(left: 40, top: 5, right: 30, bottom: 30),
    //提示的文案信息
    crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
    tooltipFormatter: (list) => TextSpan(
      text: list.map((e) => e['value1']).toString(),
      style: const TextStyle(
        color: Colors.black,
      ),
    ),
    yAxis: [
      YAxis(min: 0, max: 500, drawGrid: true),
      YAxis(min: 0, max: 400, offset: (size) => Offset(size.width - 70, 0)),
    ],
    xAxis: XAxis(
      count: 7,
      max: 20,
      drawLine: false,
      formatter: (index) => startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd'),
    ),
    charts: [
      Bar(
        color: Colors.yellow,
        data: dataList,
        yAxisPosition: 1,
        position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
        value: (item) => item['value1'],
      ),
      Line(
        data: dataList,
        position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
        values: (item) => [
          item['value1'] as num,
        ],
      ),
      Line(
        colors: [Colors.green],
        data: dataList,
        position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
        values: (item) => [
          item['value2'] as num,
        ],
      ),
    ],
  ),
),
)


```

PieChart

```dart

SizedBox(
  height: 200,
  child: ChartWidget(
    builder: () => PieChartCoordinateRender(
      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 10),
      charts: [
        Pie(
          data: dataList,
          position: (item) => (double.parse(item['value1'].toString())),
          holeRadius: 40,
          valueTextOffset: 20,
          centerTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          valueFormatter: (item) => item['value1'].toString(),
        ),
      ],
    ),
  ),
),

```
