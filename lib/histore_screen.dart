import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoryScreen extends StatefulWidget {
  final List<List<String>> value;
  final double maximum;
  final double interval;
  final String title;
  const HistoryScreen({super.key,
    required this.value,
    required this.title,
    required this.maximum,
    required this.interval,
  });
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> {
  List<_ChartData> data = [];
  List<List<String>> valueData = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    valueData = widget.value;
    valueData.sort((a, b) =>
        DateFormat("yyyy:MM:dd hh:mm:ss").parse(a[0])
        .compareTo( DateFormat("yyyy:MM:dd hh:mm:ss").parse(b[0])));

    log("${widget.title} ===========>>>>>>>> ${valueData.length}");
    for (int i= 0; i< valueData.length;i++) {
      DateTime tempDate = DateFormat("yyyy:MM:dd hh:mm:ss").parse(valueData[i][0]);
      data.add(_ChartData("${tempDate.day} "
          "${DateFormat("MMMM").format(tempDate)}",
          double.parse(valueData[i][1])));
    }

    // data.sort((a, b) => a.x.compareTo(b.x));
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black26)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      )),

                  const Icon(Icons.arrow_drop_down_outlined),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelStyle: TextStyle(fontSize: 8),
                  arrangeByIndex: true,
                ),
                primaryYAxis: NumericAxis(
                    minimum: 0,
                    labelStyle: const TextStyle(
                        fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maximum: widget.maximum,
                    interval: widget.interval),
                enableAxisAnimation: true,
                tooltipBehavior: _tooltip,
                series: <CartesianSeries<_ChartData, String>>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    name: widget.title,
                    width: 0.04,
                    // spacing: 5.5,
                    color: const Color.fromRGBO(8, 150, 245, 1),
                  ),
                ]),
            ),
          ],
        ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}