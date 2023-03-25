
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
