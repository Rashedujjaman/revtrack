import 'package:flutter/material.dart';
import 'package:revtrack/theme/gradient_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:revtrack/widgets/pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<_SalesData> data = [
    _SalesData('Jan', 50000),
    _SalesData('Feb', 280000),
    _SalesData('Mar', 120000),
    _SalesData('Apr', 520000),
    _SalesData('May', 241325),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: gradientBackground(context),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Welcome to RevTrack',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.all(20),
                //   // height: 160,
                //   decoration: BoxDecoration(
                //     borderRadius: const BorderRadius.all(
                //       Radius.circular(30),
                //     ),
                //     color: Theme.of(context).colorScheme.secondary,
                //   ),
                //   child: Center(
                //     child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: <Widget>[
                //           // Container(
                //           //   height: 120,
                //           //   width: 120,
                //           //   decoration: BoxDecoration(
                //           //     borderRadius: const BorderRadius.all(
                //           //       Radius.circular(30),
                //           //     ),
                //           //     color: Theme.of(context).colorScheme.tertiary,
                //           //   ),
                //           //   child: const CircleAvatar(
                //           //     radius: 40,
                //           //     backgroundColor:
                //           //         Color(0xFF62BDBD), // Avatar background color
                //           //     child: CircleAvatar(
                //           //       // Inner circle for the Icon
                //           //       radius:
                //           //           39, // Slightly smaller to create the border
                //           //       backgroundImage: NetworkImage(
                //           //           'https://avatars.githubusercontent.com/u/68024439?v=4'),
                //           //     ),
                //           //   ),
                //           // ),
                //           Container(
                //             height: 120,
                //             width: 120,
                //             decoration: BoxDecoration(
                //               borderRadius: const BorderRadius.all(
                //                 Radius.circular(30),
                //               ),
                //               color: Theme.of(context).colorScheme.tertiary,
                //             ),
                //             child: const Center(
                //               child: CircleAvatar(
                //                 radius: 40,
                //                 backgroundColor: Color(
                //                     0xFF62BDBD), // Avatar background color
                //                 child: CircleAvatar(
                //                   // Inner circle for the Icon
                //                   radius:
                //                       39, // Slightly smaller to create the border
                //                   backgroundImage: NetworkImage(
                //                       'https://avatars.githubusercontent.com/u/68024439?v=4'),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ]),
                //   ),
                // ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 120,
                  // width: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    ),
                    color: Theme.of(context).colorScheme.secondary.withValues(
                          alpha: .8,
                        ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Monthly Revenue : ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "2,41,325",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Yearly Revenue : ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "11,11,325",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    title:
                        const ChartTitle(text: 'Half yearly revenue analysis'),
                    legend: const Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<_SalesData, String>>[
                      LineSeries<_SalesData, String>(
                        dataSource: data,
                        xValueMapper: (_SalesData sales, _) => sales.year,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        name: 'Revenue',
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: DashboardPieChart(),
                ),
                SizedBox(
                  height: 150,
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
        ),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
