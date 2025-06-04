import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:revtrack/models/chart_data_model.dart';

class RevenuePredictionChart extends StatelessWidget {
  final String title;
  final List<ChartData> historicalData;
  final List<ChartData> predictions;

  const RevenuePredictionChart({
    Key? key,
    required this.title,
    required this.historicalData,
    required this.predictions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historicalData = this.historicalData;
    final predictions = this.predictions;

    return SfCartesianChart(
      title: ChartTitle(text: title),
      legend: const Legend(isVisible: true),
      primaryXAxis: const CategoryAxis(
        labelRotation: -45,
      ),
      primaryYAxis: const NumericAxis(
        title: AxisTitle(text: 'Amount (৳) '),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          name: 'Historical Revenue',
          dataSource: historicalData,
          xValueMapper: (ChartData data, _) => data.key,
          yValueMapper: (ChartData data, _) => data.value,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: Colors.blue,
        ),
        LineSeries<ChartData, String>(
          name: 'Predicted Revenue',
          dataSource: predictions,
          xValueMapper: (ChartData data, _) => data.key,
          yValueMapper: (ChartData data, _) => data.value,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: Colors.orange,
          dashArray: const [5, 5],
        ),
      ],
    );
  }
}
