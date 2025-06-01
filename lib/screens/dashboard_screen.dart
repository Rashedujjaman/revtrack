// import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/theme/gradient_provider.dart';
import 'package:revtrack/widgets/cartesian_chart.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:revtrack/widgets/pie_chart.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_number/animated_number.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //*************************************************************************************************************************** */
  get userId => Provider.of<UserProvider>(context, listen: false).userId;
  // final List<ChartData> data = [
  //   ChartData('Jan', 50000),
  //   ChartData('Feb', 280000),
  //   ChartData('Mar', 120000),
  //   ChartData('Apr', 520000),
  //   ChartData('May', 241325),
  // ];

  List<Business> businesses = [];
  List<Transaction1> transactions = [];
  List<ChartData> revenueTrendData = [];
  List<ChartData> revenueDistributionData = [];

  double totalMonthlyRevenue = 0.0;
  double totalYearlyRevenue = 0.0;

  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year - 1, 1, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
        23, 59, 59, 999, 999),
  );
  DateTimeRange currentMonthRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
        23, 59, 59, 999, 999),
  );

  // int currentMonth = int.parse(DateFormat('MM').format(DateTime.now()));
  // int currentYear = int.parse(DateFormat('yyyy').format(DateTime.now()));

  bool isLoading = true;
  //*************************************************************************************************************************** */

  @override
  // Initialize the state of the widget
  void initState() {
    super.initState();
    fetchBusinesses();
  }

  @override
  // Dispose method to clean up resources
  void dispose() {
    // Clean up any resources or listeners if needed
    super.dispose();
  }

  // This method is used to fetch businesses from the database
  Future<void> fetchBusinesses() async {
    try {
      businesses = await BusinessService().getBusinessesByUser(userId);
      if (businesses.isNotEmpty) {
        for (var business in businesses) {
          transactions.addAll(
            await fetchTransactions(business.id),
          );
        }
      }
      setState(() {
        if (transactions.isNotEmpty) {
          revenueDistributionData = getRevenueDistributionByBusinesses();
          revenueTrendData = getRevenueTrendData();
          totalYearlyRevenue = calculateRevenue(selectedDateRange);
          totalMonthlyRevenue = calculateRevenue(currentMonthRange);
        }
        isLoading = false;
      });
    } catch (e) {
      null; // Handle any errors that occur during the fetch
      setState(() {
        isLoading = false;
      });
    }
  }

  // This method can be used to fetch transactions from the database
  Future<List<Transaction1>> fetchTransactions(String businessId) async {
    try {
      // Fetch transactions for the given business ID and date range (selected/Default)
      return await TransactionService()
          .getTransactionsByBusiness(businessId, selectedDateRange);
    } catch (e) {
      // Handle any errors that occur during the fetch
      rethrow;
    }
  }

  double calculateTotalIncome(DateTimeRange dateRange) {
    double totalIncome = transactions
        .where((transaction) =>
            transaction.type == 'Income' &&
            transaction.dateCreated.toDate().compareTo(dateRange.start) >= 0 &&
            transaction.dateCreated.toDate().compareTo(dateRange.end) <= 0)
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
    return totalIncome;
  }

  double calculateTotalExpense(DateTimeRange dateRange) {
    double totalExpense = transactions
        .where((transaction) =>
            transaction.type == 'Expense' &&
            transaction.dateCreated.toDate().compareTo(dateRange.start) >= 0 &&
            transaction.dateCreated.toDate().compareTo(dateRange.end) <= 0)
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
    return totalExpense;
  }

  double calculateRevenue(DateTimeRange range) {
    return calculateTotalIncome(range) - calculateTotalExpense(range);
  }

  List<ChartData> getRevenueTrendData() {
    final Map<String, double> monthlyMap = {};

    for (var transaction in transactions) {
      final key = DateFormat('MMM yy').format(transaction.dateCreated.toDate());
      monthlyMap.update(
        key,
        (val) => transaction.type == 'Income'
            ? val + transaction.amount
            : val - transaction.amount,
        ifAbsent: () => transaction.type == 'Income'
            ? transaction.amount
            : -transaction.amount,
      );
    }
    // Sort the entries by date (parse the key back to DateTime)
    List<MapEntry<String, double>> sortedEntries = monthlyMap.entries.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('MMM yy').parse(a.key);
        DateTime dateB = DateFormat('MMM yy').parse(b.key);
        return dateA.compareTo(dateB);
      });

    List<ChartData> data =
        sortedEntries.map((e) => ChartData(e.key, e.value)).toList();
    return data;
  }

  // List<ChartData> getRevenueDistributionByCategory() {
  //   final Map<String, double> revenueMap = {};
  //   for (var transaction in transactions) {
  //     if (transaction.type == 'Income') {
  //       revenueMap.update(
  //         transaction.category,
  //         (val) => val + transaction.amount,
  //         ifAbsent: () => transaction.amount,
  //       );
  //     }
  //   }
  //   return revenueMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  // }

  List<ChartData> getRevenueDistributionByBusinesses() {
    final Map<String, double> revenueMap = {};
    for (var business in businesses) {
      // Calculate total income for this business
      final income = transactions
          .where((t) => t.businessId == business.id && t.type == 'Income')
          .fold(0.0, (sum, t) => sum + t.amount);
      // Calculate total expense for this business
      final expense = transactions
          .where((t) => t.businessId == business.id && t.type == 'Expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      // Revenue = Income - Expense
      revenueMap[business.name] = income - expense;
    }
    List<ChartData> data =
        revenueMap.entries.map((e) => ChartData(e.key, e.value)).toList();
    return data;
  }

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
                        color: Theme.of(context).colorScheme.surfaceDim),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Monthly Revenue : ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              // const AnimatedNumber(
                              //   startValue: 0,
                              //   endValue: 2000,
                              //   duration: Duration(seconds: 2),
                              //   isFloatingPoint: false,
                              //   style: TextStyle(
                              //     color: Colors.orange,
                              //     fontSize: 24,
                              //   ),
                              // ),
                              !isLoading
                                  ? AnimatedNumber(
                                      startValue: 0,
                                      endValue: totalMonthlyRevenue > 0
                                          ? totalMonthlyRevenue
                                          : 0.0,
                                      duration: const Duration(seconds: 2),
                                      isFloatingPoint: true,
                                      decimalPoint: 2,
                                      style: const TextStyle(
                                        color: Colors.lightBlue,
                                        fontSize: 32,
                                      ),
                                    )
                                  : Shimmer.fromColors(
                                      baseColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
                                      highlightColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: Container(
                                        width: 70,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Yearly Revenue : ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              !isLoading
                                  ? AnimatedNumber(
                                      startValue: 0,
                                      endValue: totalYearlyRevenue > 0
                                          ? totalYearlyRevenue
                                          : 0.0,
                                      duration: const Duration(seconds: 2),
                                      isFloatingPoint: true,
                                      decimalPoint: 2,
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 32,
                                      ),
                                    )
                                  : Shimmer.fromColors(
                                      baseColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
                                      highlightColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: Container(
                                        width: 70,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                              // Text(
                              //   "11,11,325",
                              //   style: TextStyle(
                              //     fontSize: 24,
                              //     fontWeight: FontWeight.bold,
                              //     color: Theme.of(context).colorScheme.tertiary,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 300,
                      child: CartesianChart(data: revenueTrendData)),
                  SizedBox(
                    height: 300,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PieChart(
                            data: revenueDistributionData,
                          ),
                  ),
                  // SizedBox(
                  //   height: 150,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     //Initialize the spark charts widget
                  //     child: SfSparkLineChart.custom(
                  //       //Enable the trackball
                  //       trackball: const SparkChartTrackball(
                  //         activationMode: SparkChartActivationMode.tap,
                  //       ),
                  //       //Enable marker
                  //       marker: const SparkChartMarker(
                  //         displayMode: SparkChartMarkerDisplayMode.all,
                  //       ),
                  //       //Enable data label
                  //       labelDisplayMode: SparkChartLabelDisplayMode.all,
                  //       xValueMapper: (int index) => data[index].key,
                  //       yValueMapper: (int index) => data[index].value,
                  //       dataCount: 5,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
