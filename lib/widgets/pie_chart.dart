import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPieChart extends StatelessWidget {
  DashboardPieChart({super.key});
  final List<CompanyRevenueData> data = [
    CompanyRevenueData('Com A', 35000),
    CompanyRevenueData('Com B', 50000),
    CompanyRevenueData('Com C', 25000),
    CompanyRevenueData('Com D', 45000),
    CompanyRevenueData('Com E', 30000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Revenue Distribution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SfCircularChart(
            legend: const Legend(isVisible: true),
            onLegendItemRender: (LegendRenderArgs args) {
              if (args.text == 'Com A') {
                args.color = Colors.red;
              }
            },
            series: <PieSeries<CompanyRevenueData, String>>[
              PieSeries<CompanyRevenueData, String>(
                dataSource: data,
                xValueMapper: (CompanyRevenueData data, _) => data.companyName,
                yValueMapper: (CompanyRevenueData data, _) => data.revenue,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyRevenueData {
  final String companyName;
  final double revenue;

  CompanyRevenueData(this.companyName, this.revenue);
}
