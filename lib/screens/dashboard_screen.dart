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
import 'package:revtrack/widgets/revenue_prediction_chart.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_number/animated_number.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //*************************************************************************************************************************** */
  // get userId => Provider.of<UserProvider>(context, listen: false).userId;

  // State variables
  List<Business> businesses = [];
  List<Transaction1> transactions = [];
  List<ChartData> revenueTrendData = [];
  List<ChartData> revenueDistributionData = [];
  List<ChartData> predictedRevenueData = [];

  double totalMonthlyRevenue = 0.0;
  double totalYearlyRevenue = 0.0;
  bool isLoading = true;
  String? errorMessage;

  // Date ranges
  late DateTimeRange selectedDateRange;
  late DateTimeRange currentMonthRange;

  // int currentMonth = int.parse(DateFormat('MM').format(DateTime.now()));
  // int currentYear = int.parse(DateFormat('yyyy').format(DateTime.now()));

  //*************************************************************************************************************************** */

  @override
  // Initialize the state of the widget
  void initState() {
    super.initState();
    // Initialize date ranges
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
    currentMonthRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );

    // Load data
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      // 1. Fetch businesses
      final fetchedBusinesses =
          await BusinessService().getBusinessesByUser(userId);

      // 2. Fetch transactions for all businesses in parallel
      final allTransactions = await Future.wait(fetchedBusinesses
              .map((business) => fetchTransactions(business.id)))
          .then((listOfLists) => listOfLists.expand((list) => list).toList());

      // 3. Calculate metrics
      final yearlyRevenue =
          calculateRevenue(allTransactions, selectedDateRange);
      final monthlyRevenue =
          calculateRevenue(allTransactions, currentMonthRange);
      final distributionData = getRevenueDistributionByBusinesses(
          fetchedBusinesses, allTransactions);
      final trendData = getRevenueTrendData(allTransactions);
      final predictions = predictFutureRevenue(trendData);

      // Single state update with all new data
      setState(() {
        businesses = fetchedBusinesses;
        transactions = allTransactions;
        totalYearlyRevenue = yearlyRevenue;
        totalMonthlyRevenue = monthlyRevenue;
        revenueDistributionData = distributionData;
        revenueTrendData = trendData;
        predictedRevenueData = predictions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load dashboard data: ${e.toString()}';
        isLoading = false;
      });
      // Consider logging the error to your error tracking service
      debugPrint('Dashboard loading error: $e');
    }
  }

  // Helper method to refresh data
  Future<void> _refreshData() async {
    await _loadDashboardData();
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

  double calculateTotalIncome(
      List<Transaction1> transactions, DateTimeRange dateRange) {
    double totalIncome = transactions
        .where((transaction) =>
            transaction.type == 'Income' &&
            transaction.dateCreated.toDate().compareTo(dateRange.start) >= 0 &&
            transaction.dateCreated.toDate().compareTo(dateRange.end) <= 0)
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
    return totalIncome;
  }

  double calculateTotalExpense(
      List<Transaction1> transactions, DateTimeRange dateRange) {
    double totalExpense = transactions
        .where((transaction) =>
            transaction.type == 'Expense' &&
            transaction.dateCreated.toDate().compareTo(dateRange.start) >= 0 &&
            transaction.dateCreated.toDate().compareTo(dateRange.end) <= 0)
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
    return totalExpense;
  }

  double calculateRevenue(
      List<Transaction1> transactions, DateTimeRange range) {
    return calculateTotalIncome(transactions, range) -
        calculateTotalExpense(transactions, range);
  }

  List<ChartData> getRevenueTrendData(List<Transaction1> transactions) {
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

    // Convert to list and sort by date
    var sortedData = monthlyMap.entries
        .map((e) => ChartData(e.key, e.value))
        .toList()
      ..sort((a, b) => DateFormat('MMM yy')
          .parse(a.key)
          .compareTo(DateFormat('MMM yy').parse(b.key)));

    return sortedData;
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

  List<ChartData> getRevenueDistributionByBusinesses(
      List<Business> businesses, List<Transaction1> transactions) {
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

  List<ChartData> predictFutureRevenue(
    List<ChartData> historicalData, {
    int monthsToPredict = 6,
  }) {
    if (historicalData.isEmpty) return [];

    // Prepare data for ML algorithm
    final dates = historicalData.map((data) {
      final date = DateFormat('MMM yy').parse(data.key);
      return date.millisecondsSinceEpoch.toDouble();
    }).toList();

    final values = historicalData.map((data) => data.value).toList();

    // Create dataframe - UPDATED API USAGE
    final dataframe = DataFrame([
      ['time', 'value'],
      for (var i = 0; i < dates.length; i++) [dates[i], values[i]],
    ], headerExists: true);

    // Create and train model
    final model = LinearRegressor(
      dataframe,
      'value',
      optimizerType: LinearOptimizerType.closedForm,
    );

    // Generate predictions
    final lastDate = DateFormat('MMM yy').parse(historicalData.last.key);
    final predictions = <ChartData>[];

    for (int i = 1; i <= monthsToPredict; i++) {
      final futureDate = DateTime(
        lastDate.year,
        lastDate.month + i,
      );

      // UPDATED PREDICTION API USAGE
      final predictionData = DataFrame([
        ['time'],
        [futureDate.millisecondsSinceEpoch.toDouble()],
      ], headerExists: true);

      final prediction = model.predict(predictionData);
      final predictedValue = prediction.rows.first.first;

      predictions.add(ChartData(
        DateFormat('MMM yy').format(futureDate),
        predictedValue,
      ));
    }

    return predictions;
  }

  @override
  Widget build(BuildContext context) {
    //     if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: gradientBackground(context),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            // child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16.0,
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
                                    highlightColor:
                                        Theme.of(context).colorScheme.secondary,
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
                                    highlightColor:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Container(
                                      width: 70,
                                      height: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                isLoading
                    ? const CartesianChartSkeleton()
                    : CartesianChart(
                        data: revenueTrendData, title: 'Revenue Trend'),
                isLoading
                    ? const PieChartSkeleton()
                    : PieChart(
                        data: revenueDistributionData,
                        title: 'Revenue Distribution',
                      ),

                isLoading
                    ? const CartesianChartSkeleton()
                    : RevenuePredictionChart(
                        transactions: transactions,
                        historicalData: revenueTrendData,
                        predictions: predictedRevenueData)

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
            // ),
          ),
        ),
      ),
    );
  }
}
