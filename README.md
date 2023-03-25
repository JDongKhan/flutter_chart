
## Flutter_chart

这是一款轻量级的flutter版本chart组件，目前已支持LineChart、BarChart、PieChart。

该组件支持缩放、水平滚动、选中变色、自定义标注等基础功能，并且使用很简单，代码量极少，可扩展性极强。

### 为何自己造轮子？
市面上有很多种chart，经过长时间的调研，发现没有一款完成符合自己需求的组件，有的样式太过个性化比如fl_chart，有的功能太简单，找了许久感觉graphic最合适，但是在项目使用过程中发现一些bug，也和作者沟通过，但是响应不及时造就了项目出现风险。
而这个库对标的是echart，概念也较新，作者最近更新频率又较低，所有目前来看路还很长，后来想了想我们的需求也不复杂，但是使用了第三方库就意味着要去熟悉它的api和逻辑，如果是已成熟的还好，这种未来不可知的费这精力不如自己造。
还有一点是一些组件为设计可能对数据各种遍历，当数据量大的时候会有性能瓶颈问题，比如graphic只支持一个数组，那么像一个数组要画多条线时需要自己来循环磨平，再加上框架各种计算数组会循环很多遍。

当然自己造了个轮子也不是什么都支持的，所以首要目的是满足基本功能之余代码尽可能精简、独立，让使用者可以二次开发或者在之前的基础上容易扩展，最主要的是本组件支持数组内画多条图形，而仅仅一次遍历就可以了。


本项目是基于坐标系+图形两种概念实现，提供了两个坐标系：LineBarChartCoordinateRender和PieChartCoordinateRender圆形 + 各种对应的图形render。

当然了，如果满足不了你的需求，你可以重写ChartRender自己绘制，如果是需要增强能力则可以通过增加Annotation（在example中有使用，可以查看如何使用），甚至可以自定义Annotation。

![demo png](1.gif "demo")
![demo png](2.gif "demo")
![demo png](3.gif "demo")

![demo png](1.png "demo")

BarChart:
```dart

      SizedBox(
            width: 250,
            height: 200,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                position: (item) {
                  return (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000);
                },
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                yAxis: YAxis(min: 0, max: 1000),
                xAxis: XAxis(
                  count: 7,
                  max: 30,
                  formatter: (index) {
                    return startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd');
                  },
                ),
                data: dataList,
                chartRender: StackBar(
                  direction: Axis.vertical,
                  itemWidth: 10,
                  highlightColor: Colors.yellow,
                  position: (item) => [
                    double.parse(item['value1'].toString()),
                    double.parse(item['value2'].toString()),
                    double.parse(item['value3'].toString()),
                  ],
                ),
              ),
            ),
          ),
      

```

LineChart

```dart
       SizedBox(
            width: 250,
            height: 200,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                zoom: true,
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                //提示的文案信息
                tooltipFormatter: (item) => TextSpan(
                  text: '${item['value1']}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                position: (item) => (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000),
                yAxis: YAxis(min: 0, max: 500),
                xAxis: XAxis(
                  count: 7,
                  max: 7,
                  formatter: (index) => startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd'),
                ),
                chartRender: Line(
                  position: (item) => [
                    item['value1'] as num,
                  ],
                ),
                data: dataList,
              ),
            ),
          ),

```

BarChart

```dart

       SizedBox(
            height: 200,
            width: 250,
            child: ChartWidget(
              builder: (controller) => PieChartCoordinateRender(
                data: dataList,
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 10),
                position: (item) => (double.parse(item['value1'].toString())),
                chartRender: Pie(
                  holeRadius: 40,
                  valueTextOffset: 20,
                  centerTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  valueFormatter: (item) => item['value1'].toString(),
                ),
              ),
            ),
          ),

```
