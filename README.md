
## Flutter_chart

这是一款轻量的flutter版本chart组件，目前已支持LineChart、BarChart、PieChart。

该组件支持缩放、水平滚动、选中变色等基础功能，并且使用很简单，代码量极少，可扩展性极强。



![demo png](1.gif "demo")
![demo png](2.gif "demo")
![demo png](3.gif "demo")

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
