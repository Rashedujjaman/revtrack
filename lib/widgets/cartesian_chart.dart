import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CartesianChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  const CartesianChart({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      legend: const Legend(isVisible: true),
      primaryXAxis: const CategoryAxis(
        labelRotation: -90,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData sales, _) => sales.key,
          yValueMapper: (ChartData sales, _) => sales.value,
          name: 'Revenue',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }
}
