import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CartesianChart extends StatelessWidget {
  final List<ChartData> data;
  const CartesianChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          title: const ChartTitle(text: 'Monthly revenue analysis'),
          legend: const Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<ChartData, String>>[
            LineSeries<ChartData, String>(
              dataSource: data,
              xValueMapper: (ChartData sales, _) => sales.key,
              yValueMapper: (ChartData sales, _) => sales.value,
              name: 'Revenue',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}
