import 'dart:ui' as ui;

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class LineChartDemoPage extends StatefulWidget {
  const LineChartDemoPage({Key? key}) : super(key: key);

  @override
  State<LineChartDemoPage> createState() => _LineChartDemoPageState();
}

class _LineChartDemoPageState extends State<LineChartDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  ui.Image? logoImage;

  @override
  void initState() {
    ImageAnnotation.getAssetImage('images/location.png', width: 15, height: 15).then((value) {
      setState(() {
        logoImage = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
      {
        'time': startTime.add(const Duration(days: 1)),
        'value1': 100,
        'value2': 200,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 3)),
        'value1': 150,
        'value2': 250,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 5)),
        'value1': 200,
        'value2': 280,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 300,
        'value2': 450,
        'value3': 300,
      },
    ];

    final ChartController controller = ChartController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('single data source,single Line'),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    foregroundWidget: const Positioned(right: 0, bottom: 40, child: Icon(Icons.ad_units, color: Colors.blue)),
                    coordinateRender: ChartDimensionsCoordinateRender(
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      animationDuration: const Duration(seconds: 1),
                      //提示的文案信息
                      tooltipBuilder: (BuildContext context, List<ChartLayoutState> body) {
                        String text = '我可以滚动我可以滚动\n我可以滚动我可以滚动\n我可以滚动我可以滚动\n我可以滚动我可以滚动';
                        return PreferredSize(
                          preferredSize: const Size(60, 100),
                          child: SizedBox(
                            width: 60,
                            height: 100,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Text(text),
                              ),
                            ),
                          ),
                        );
                      },
                      yAxis: [YAxis(min: 0, max: 500)],
                      xAxis: XAxis(
                        count: 9,
                        zoom: true,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Line(
                          data: dataList,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          values: (item) => [
                            item['value1'] as num,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Text('single data source,multiple Line'),
                SizedBox(
                  // color: Colors.yellow,
                  height: 200,
                  child: ChartWidget(
                    controller: controller,
                    coordinateRender: ChartDimensionsCoordinateRender(
                      foregroundAnnotations: [
                        LimitAnnotation(limit: 380),
                        LimitAnnotation(limit: 210),
                        if (logoImage != null)
                          ImageAnnotation(
                            image: logoImage!,
                            onTap: (ann) {
                              print('点击事件');
                              controller.showTooltipBuilder(
                                builder: (c) {
                                  return PreferredSize(
                                    preferredSize: const Size(60, 60),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Text('1111'),
                                    ),
                                  );
                                },
                                position: ann.rect!.bottomCenter,
                              );
                            },
                            positions: [1, 200],
                          ),
                        LabelAnnotation(positions: [6, 380], text: '380', fixed: true),
                      ],
                      backgroundAnnotations: [
                        RegionAnnotation(positions: [2.4, 3.3]),
                        RegionAnnotation(positions: [4.4, 5.3]),
                      ],
                      margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                      //提示的文案信息
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      tooltipBuilder: (BuildContext context, List<ChartLayoutState> body) {
                        return PreferredSize(
                          preferredSize: const Size(60, 60),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(body.map((e) => e.selectedIndex).toString()),
                          ),
                        );
                      },
                      yAxis: [
                        YAxis(min: 100, max: 500, drawGrid: true),
                      ],
                      xAxis: XAxis(
                        count: 7,
                        max: 20,
                        zoom: true,
                        drawGrid: true,
                        drawLine: true,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Line(
                          data: dataList,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          values: (item) => [
                            item['value1'] as num,
                            item['value2'] as num,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  // color: Colors.yellow,
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                      //提示的文案信息
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      tooltipBuilder: (BuildContext context, List<ChartLayoutState> body) {
                        return PreferredSize(
                          preferredSize: const Size(60, 60),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(body.map((e) => e.selectedIndex).toString()),
                          ),
                        );
                      },
                      yAxis: [
                        YAxis(min: 0, max: 500, drawGrid: true),
                      ],
                      xAxis: XAxis(
                        count: 9,
                        drawGrid: true,
                        zoom: true,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Line(
                          data: dataList,
                          //填充需要开启这个属性
                          filled: true,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          colors: [Colors.blue, Colors.red],
                          dotColors: [Colors.blue, Colors.black],
                          shaders: [
                            ui.Gradient.linear(Offset.zero, const Offset(0, 200), [
                              Colors.red.withOpacity(0.3),
                              Colors.black.withOpacity(0.5),
                            ]),
                            ui.Gradient.linear(Offset.zero, const Offset(0, 200), [
                              Colors.blue.withOpacity(0.5),
                              Colors.yellow.withOpacity(0.5),
                            ]),
                          ],
                          values: (item) => [
                            item['value2'] as num,
                            item['value1'] as num,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Text('shaders'),
                SizedBox(
                  // color: Colors.yellow,
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                      //提示的文案信息
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      tooltipBuilder: (BuildContext context, List<ChartLayoutState> body) {
                        return PreferredSize(
                          preferredSize: const Size(60, 60),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(body.map((e) => e.selectedIndex).toString()),
                          ),
                        );
                      },
                      yAxis: [
                        YAxis(min: 0, max: 500, drawGrid: true),
                      ],
                      xAxis: XAxis(
                        count: 9,
                        max: 9,
                        zoom: true,
                        drawGrid: true,
                        drawLine: true,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Line(
                          data: dataList,
                          //填充需要开启这个属性
                          filled: true,
                          operation: PathOperation.xor,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          colors: [Colors.transparent, Colors.blue],
                          dotColors: [Colors.black, Colors.black],
                          // shaders: [
                          //   ui.Gradient.linear(Offset.zero, Offset(1000, 1000), [
                          //     Colors.red,
                          //     Colors.red,
                          //   ]),
                          //   ui.Gradient.linear(Offset.zero, Offset(1000, 1000), [
                          //     Colors.blue,
                          //     Colors.blue,
                          //   ]),
                          // ],
                          values: (item) => [
                            item['value1'] as num,
                            item['value2'] as num,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  // color: Colors.yellow,
                  height: 200,
                  child: LayoutBuilder(builder: (context, cs) {
                    return ChartWidget(
                      coordinateRender: ChartDimensionsCoordinateRender(
                        margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                        //提示的文案信息
                        crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                        tooltipBuilder: (BuildContext context, List<ChartLayoutState> body) {
                          return PreferredSize(
                            preferredSize: const Size(60, 60),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(body.map((e) => e.selectedIndex).toString()),
                            ),
                          );
                        },
                        yAxis: [
                          YAxis(min: 0, max: 500, drawGrid: true),
                        ],
                        xAxis: XAxis(
                          count: 7,
                          max: 20,
                          zoom: true,
                          drawGrid: true,
                          drawLine: true,
                          formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                        ),
                        charts: [
                          Line(
                            data: dataList,
                            position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                            dotColors: [
                              Colors.black,
                              Colors.black,
                            ],
                            shaders: [
                              //https://juejin.cn/post/6938371371760091150 具体如何使用可参考此文章
                              ui.Gradient.linear(
                                Offset.zero,
                                const Offset(0.0, 10.0),
                                <Color>[Colors.black, Colors.yellow, Colors.yellow, Colors.yellow],
                                <double>[0.25, 0.25, 0.75, 0.75],
                                TileMode.repeated,
                              ),
                              ui.Gradient.linear(
                                Alignment.topCenter.withinRect(Rect.fromLTWH(0, 0, cs.maxWidth, cs.maxHeight)),
                                Alignment.bottomCenter.withinRect(Rect.fromLTWH(0, 0, cs.maxWidth, cs.maxHeight)),
                                <Color>[Colors.blue, Colors.yellow, Colors.yellow, Colors.yellow],
                                <double>[0.25, 0.25, 0.75, 0.75],
                                TileMode.clamp,
                              ),
                            ],
                            values: (item) => [
                              item['value1'] as num,
                              item['value2'] as num,
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const Text('multiple data source,multiple line/bar'),
                SizedBox(
                  // color: Colors.yellow,
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      margin: const EdgeInsets.only(left: 40, top: 5, right: 30, bottom: 30),
                      //提示的文案信息
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      tooltipBuilder: (BuildContext context, List<ChartLayoutState> body) {
                        return PreferredSize(
                          preferredSize: const Size(60, 60),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(body.map((e) => e.selectedIndex).toString()),
                          ),
                        );
                      },
                      yAxis: [
                        YAxis(min: 0, max: 500, drawGrid: true),
                        YAxis(
                          min: 0,
                          max: 400,
                          padding: 5,
                          drawDivider: false,
                          offset: (size) => Offset(size.width - 70, 0),
                        ),
                      ],
                      xAxis: XAxis(
                        count: 7,
                        max: 20,
                        drawLine: false,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Bar(
                          color: Colors.green,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
