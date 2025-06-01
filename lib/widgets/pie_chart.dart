// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final Color? borderColor;

  const PieChart(
      {super.key, required this.data, required this.title, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(text: title),
      borderColor: borderColor ?? Colors.transparent,
      borderWidth: 1,
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
          // pointColorMapper: (ChartData data, _) {
          //   // You can customize the color mapping here
          //   int total = data.value.toInt();
          //   if (total < 0) {
          //     return Colors.red; // Negative values in red
          //   }
          //   // Use the index to assign unique colors for each company
          //   return Colors
          //       .primaries[data.key.hashCode % Colors.primaries.length];
          // },
        ),
      ],
    );
  }
}
