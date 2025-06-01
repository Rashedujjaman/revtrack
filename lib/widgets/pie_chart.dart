import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChart extends StatelessWidget {
  final List<ChartData> data;
  const PieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SfCircularChart(
          title: const ChartTitle(text: 'Revenue Distribution'),
          tooltipBehavior: TooltipBehavior(enable: true),
          legend: const Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom,
            // alignment: ChartAlignment.far,
          ),
          series: <PieSeries<ChartData, String>>[
            PieSeries<ChartData, String>(
              dataSource: data,
              xValueMapper: (ChartData data, _) => data.key,
              yValueMapper: (ChartData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.curve,
                  length: '15%',
                ),
              ),
              explode: true,
              pointColorMapper: (ChartData data, _) {
                // You can customize the color mapping here
                int total = data.value.toInt();
                if (total < 0) {
                  return Colors.red; // Negative values in red
                }
                // return Colors
                //     .primaries[data.value.toInt() % Colors.primaries.length];
              },
            ),
          ],
        ),
      ),
    );
  }
}
