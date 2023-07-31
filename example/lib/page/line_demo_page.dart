import 'dart:ui' as ui;

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/flutter_chart.dart';

/// @author JD
class LineChartDemoPage extends StatefulWidget {
  LineChartDemoPage({Key? key}) : super(key: key);

  @override
  State<LineChartDemoPage> createState() => _LineChartDemoPageState();
}

class _LineChartDemoPageState extends State<LineChartDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  ui.Image? logoImage;

  @override
  void initState() {
    ImageAnnotation.getAssetImage('images/location.png', width: 10, height: 10).then((value) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ChartWidget(
              coordinateRender: DimensionsChartCoordinateRender(
                zoomHorizontal: true,
                // zoomVertical: true,
                crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                //提示的文案信息
                tooltipFormatter: (list) {
                  return TextSpan(
                    text: list.map((e) => e.selectedIndex).toString(),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  );
                },
                yAxis: [
                  YAxis(
                    min: 0,
                    max: 500,
                    drawGrid: true,
                  ),
                ],
                xAxis: XAxis(
                  count: 7,
                  max: 9,
                  divideCount: (zoom) => zoom.toInt(),
                  formatter: (index) {
                    double hours = (index % 1.0) * 24;
                    double minutes = (hours % 1.0) * 60;
                    if (hours == 0) {
                      return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'MM-dd');
                    } else {
                      return startTime.add(Duration(days: index.toInt(), hours: hours.toInt(), minutes: minutes.toInt())).toStringWithFormat(format: 'HH:mm');
                    }
                  },
                ),
                backgroundAnnotations: [
                  RegionAnnotation(positions: [2.4, 3.3]),
                  RegionAnnotation(positions: [4.4, 5.3]),
                  LabelAnnotation(
                    positions: [3.3, 0],
                    text: '夜晚',
                    textAlign: TextAlign.end,
                    minZoomVisible: 1,
                    maxZoomVisible: 4,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    offset: const Offset(-10, -20),
                  ),
                  LabelAnnotation(
                    positions: [3.3, 0],
                    text: '白天',
                    minZoomVisible: 1,
                    maxZoomVisible: 4,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                    offset: const Offset(10, -20),
                  ),
                ],
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
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ChartWidget(
                          coordinateRender: DimensionsChartCoordinateRender(
                            crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                            margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                            //提示的文案信息
                            tooltipFormatter: (list) {
                              return TextSpan(
                                text: list.map((e) => e.selectedIndex).toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              );
                            },
                            yAxis: [
                              YAxis(
                                min: 0,
                                max: 500,
                              )
                            ],
                            xAxis: XAxis(
                              count: 7,
                              max: 7,
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
                      const Text('Single data,Multiple Line'),
                      SizedBox(
                        // color: Colors.yellow,
                        height: 200,
                        child: ChartWidget(
                          coordinateRender: DimensionsChartCoordinateRender(
                            zoomHorizontal: true,
                            foregroundAnnotations: [
                              LimitAnnotation(limit: 380),
                              LimitAnnotation(limit: 210),
                              if (logoImage != null)
                                ImageAnnotation(
                                  image: logoImage!,
                                  onTap: (ann) {
                                    print('点击事件');
                                  },
                                  positions: [1, 200],
                                ),
                              LabelAnnotation(positions: [6, 380], text: '380', scroll: false),
                            ],
                            backgroundAnnotations: [
                              RegionAnnotation(positions: [2.4, 3.3]),
                              RegionAnnotation(positions: [4.4, 5.3]),
                            ],
                            margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                            //提示的文案信息
                            crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                            tooltipFormatter: (list) => TextSpan(
                              text: list.map((e) => e.selectedIndex).toString(),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            yAxis: [
                              YAxis(
                                min: 0,
                                max: 500,
                                drawGrid: true,
                              ),
                            ],
                            xAxis: XAxis(
                              count: 7,
                              max: 20,
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
                      const Text('Shaders'),
                      SizedBox(
                        // color: Colors.yellow,
                        height: 200,
                        child: ChartWidget(
                          coordinateRender: DimensionsChartCoordinateRender(
                            zoomHorizontal: true,
                            margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                            //提示的文案信息
                            crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                            tooltipFormatter: (list) => TextSpan(
                              text: list.map((e) => e.selectedIndex).toString(),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            yAxis: [
                              YAxis(
                                min: 0,
                                max: 500,
                                drawGrid: true,
                              ),
                            ],
                            xAxis: XAxis(
                              count: 7,
                              max: 20,
                              drawGrid: true,
                              drawLine: true,
                              formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                            ),
                            charts: [
                              Line(
                                data: dataList,
                                //需要开启这个属性
                                filled: true,
                                operation: PathOperation.xor,
                                position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                                colors: [
                                  Colors.transparent,
                                  Colors.blue,
                                ],
                                dotColors: [
                                  Colors.black,
                                  Colors.black,
                                ],
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
                        child: ChartWidget(
                          coordinateRender: DimensionsChartCoordinateRender(
                            zoomHorizontal: true,
                            margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                            //提示的文案信息
                            crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                            tooltipFormatter: (list) => TextSpan(
                              text: list.map((e) => e.selectedIndex).toString(),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            yAxis: [
                              YAxis(
                                min: 0,
                                max: 500,
                                drawGrid: true,
                              ),
                            ],
                            xAxis: XAxis(
                              count: 7,
                              max: 20,
                              drawGrid: true,
                              drawLine: true,
                              formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                            ),
                            charts: [
                              Line(
                                data: dataList,
                                //需要开启这个属性
                                position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                                dotColors: [
                                  Colors.black,
                                  Colors.black,
                                ],
                                shaders: [
                                  ui.Gradient.linear(
                                    Offset.zero,
                                    const Offset(0.0, 10.0),
                                    <Color>[Colors.black, Colors.yellow, Colors.yellow, Colors.black],
                                    <double>[0.25, 0.25, 0.75, 0.75],
                                    TileMode.repeated,
                                  ),
                                  ui.Gradient.linear(
                                    Offset.zero,
                                    const Offset(0, 200),
                                    <Color>[Colors.blue, Colors.blue, Colors.yellow, Colors.yellow, Colors.yellow],
                                    <double>[0.25, 0.25, 0.75, 0.75, 1],
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
                        ),
                      ),
                      const Text('Multiple data,Multiple Line'),
                      SizedBox(
                        // color: Colors.yellow,
                        height: 200,
                        child: ChartWidget(
                          coordinateRender: DimensionsChartCoordinateRender(
                            margin: const EdgeInsets.only(left: 40, top: 5, right: 30, bottom: 30),
                            //提示的文案信息
                            crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                            tooltipFormatter: (list) {
                              int? selectIndex1 = list[0].selectedIndex;
                              int? selectIndex2 = list[0].selectedIndex;
                              int? selectIndex3 = list[0].selectedIndex;
                              if (selectIndex1 == null && selectIndex2 == null && selectIndex3 == null) {
                                return null;
                              }
                              return TextSpan(
                                text: list.map((e) => e.selectedIndex).toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              );
                            },
                            yAxis: [
                              YAxis(min: 0, max: 500, drawGrid: true),
                              YAxis(
                                min: 0,
                                max: 400,
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
          ),
        ],
      ),
    );
  }
}
