import 'package:flutter/material.dart';
import 'package:revtrack/theme/gradient_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: gradientBackground(context),
        child: Center(
            child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              // height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: const Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Color(0xFF62BDBD), // Avatar background color
                            child: CircleAvatar(
                              // Inner circle for the Icon
                              radius:
                                  39, // Slightly smaller to create the border
                              backgroundImage: NetworkImage(
                                  'https://avatars.githubusercontent.com/u/68024439?v=4'),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: const Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Color(0xFF62BDBD), // Avatar background color
                            child: CircleAvatar(
                              // Inner circle for the Icon
                              radius:
                                  39, // Slightly smaller to create the border
                              backgroundImage: NetworkImage(
                                  'https://avatars.githubusercontent.com/u/68024439?v=4'),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 120,
              // width: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF62BDBD), // Avatar background color
                  child: CircleAvatar(
                    // Inner circle for the Icon
                    radius: 49, // Slightly smaller to create the border
                    backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/68024439?v=4'),
                  ),
                ),
              ),
            ),
            //Initialize the chart widget
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              // Chart title
              title: const ChartTitle(text: 'Half yearly sales analysis'),
              // Enable legend
              legend: const Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                  dataSource: data,
                  xValueMapper: (_SalesData sales, _) => sales.year,
                  yValueMapper: (_SalesData sales, _) => sales.sales,
                  name: 'Sales',
                  // Enable data label
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                //Initialize the spark charts widget
                child: SfSparkLineChart.custom(
                  //Enable the trackball
                  trackball: const SparkChartTrackball(
                    activationMode: SparkChartActivationMode.tap,
                  ),
                  //Enable marker
                  marker: const SparkChartMarker(
                    displayMode: SparkChartMarkerDisplayMode.all,
                  ),
                  //Enable data label
                  labelDisplayMode: SparkChartLabelDisplayMode.all,
                  xValueMapper: (int index) => data[index].year,
                  yValueMapper: (int index) => data[index].sales,
                  dataCount: 5,
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
