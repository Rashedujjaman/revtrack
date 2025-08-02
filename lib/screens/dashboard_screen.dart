import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/services/user_stats_service.dart';
import 'package:revtrack/theme/gradient_provider.dart';
import 'package:revtrack/widgets/cartesian_chart.dart';
import 'package:revtrack/widgets/pie_chart.dart';
import 'package:revtrack/widgets/summary_card.dart';
import 'package:revtrack/widgets/safe_chart_container.dart';
import 'package:revtrack/widgets/revenue_prediction_chart.dart';
import 'package:revtrack/widgets/skeleton.dart';

/// Dashboard screen displaying user's financial overview and analytics
/// 
/// Features:
/// - Instant summary from user-level aggregated stats
/// - Lazy-loading detailed analytics with "Load Analytics" button
/// - Revenue trends, distribution charts, and ML-based predictions
/// - Optimized for cost efficiency by avoiding expensive real-time queries
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  
  // Core data
  List<Business> businesses = [];
  List<Transaction1> transactions = [];
  List<ChartData> revenueTrendData = [];
  List<ChartData> revenueDistributionData = [];
  List<ChartData> predictedRevenueData = [];

  // Aggregated stats (loaded instantly from user document)
  double totalMonthlyRevenue = 0.0;
  double totalYearlyRevenue = 0.0;
  double totalRevenue = 0.0;
  double totalIncomes = 0.0;
  double totalExpenses = 0.0;
  int totalTransactions = 0;
  
  // Loading states for different sections
  bool isInitialLoading = true;
  bool isChartsLoading = false;
  bool areChartsLoaded = false;
  bool _disposed = false;
  String? errorMessage;

  // Date ranges for data filtering
  late DateTimeRange selectedDateRange;
  late DateTimeRange currentMonthRange;

  @override
  void initState() {
    super.initState();
    _initializeDateRanges();
    _loadInitialData();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Initializes date ranges for current year and month
  void _initializeDateRanges() {
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
    currentMonthRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  /// Loads essential summary data from user stats (single document read)
  /// This provides instant dashboard summary without expensive queries
  Future<void> _loadInitialData() async {
    try {
      if (_disposed) return;

      setState(() {
        isInitialLoading = true;
        errorMessage = null;
      });

      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      // Get user stats (single document read!)
      final userStats = await UserStatsService.getUserStats(userId);
      
      // Fetch businesses for business cards display
      final fetchedBusinesses = await BusinessService().getBusinessesByUser(userId);

      if (_disposed) return;

      setState(() {
        businesses = fetchedBusinesses;
        totalRevenue = userStats['totalRevenue'] ?? 0.0;
        totalIncomes = userStats['totalIncomes'] ?? 0.0;
        totalExpenses = userStats['totalExpenses'] ?? 0.0;
        totalTransactions = userStats['totalTransactions'] ?? 0;
        isInitialLoading = false;
      });
    } catch (e) {
      if (_disposed) return;

      setState(() {
        errorMessage = 'Failed to load dashboard: ${e.toString()}';
        isInitialLoading = false;
      });
      debugPrint('Dashboard initial loading error: $e');
    }
  }

  /// Loads detailed analytics data including charts and predictions
  /// This is an expensive operation that fetches all transactions for comprehensive analysis
  /// Only called when user explicitly requests analytics via "Load Analytics" button
  Future<void> _loadAnalyticsData() async {
    try {
      if (_disposed) return;

      setState(() {
        isChartsLoading = true;
        errorMessage = null;
      });

      // Fetch all transactions for charts (expensive operation)
      final allTransactions = await Future.wait(businesses
              .map((business) => fetchTransactions(business.id)))
          .then((listOfLists) => listOfLists.expand((list) => list).toList());

      if (_disposed) return;

      // Calculate detailed metrics for charts
      final yearlyRevenue = calculateRevenue(allTransactions, selectedDateRange);
      final monthlyRevenue = calculateRevenue(allTransactions, currentMonthRange);
      final distributionData = getRevenueDistributionByBusinesses(businesses, allTransactions);
      final trendData = getRevenueTrendData(allTransactions);
      final predictions = predictFutureRevenue(trendData);

      if (_disposed) return;

      setState(() {
        transactions = allTransactions;
        totalYearlyRevenue = yearlyRevenue;
        totalMonthlyRevenue = monthlyRevenue;
        revenueDistributionData = distributionData;
        revenueTrendData = trendData;
        predictedRevenueData = predictions;
        isChartsLoading = false;
        areChartsLoaded = true;
      });
    } catch (e) {
      if (_disposed) return;

      setState(() {
        errorMessage = 'Failed to load analytics: ${e.toString()}';
        isChartsLoading = false;
      });
      debugPrint('Analytics loading error: $e');
    }
  }

  // Helper method to refresh initial data
  Future<void> _refreshData() async {
    await _loadInitialData();
    if (areChartsLoaded) {
      await _loadAnalyticsData();
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

  /// Calculates net revenue (income - expenses) for given date range
  /// 
  /// Parameters:
  /// - [transactions]: List of transactions to calculate from
  /// - [range]: Date range to filter transactions
  double calculateRevenue(List<Transaction1> transactions, DateTimeRange range) {
    return calculateTotalIncome(transactions, range) -
        calculateTotalExpense(transactions, range);
  }

  /// Generates revenue trend data grouped by month for charts
  /// 
  /// Returns a list of ChartData objects with month labels and revenue values
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

  /// Generates revenue distribution data by business for pie charts
  /// 
  /// Parameters:
  /// - [businesses]: List of businesses to analyze
  /// - [transactions]: All transactions to calculate distribution from
  /// 
  /// Returns ChartData objects with business names and net revenue values
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

  /// Predicts future revenue using machine learning linear regression
  /// 
  /// Parameters:
  /// - [historicalData]: Historical revenue trend data for training
  /// - [monthsToPredict]: Number of months to predict (default: 6)
  /// 
  /// Returns ChartData objects with predicted revenue values for future months
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
    super.build(context);
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
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16.0,
                children: <Widget>[
                  // Quick Summary (loaded immediately)
                  MultiSummaryCard(
                    title: 'Business Overview',
                    isLoading: isInitialLoading,
                    items: [
                      SummaryItem(
                        label: 'Total Revenue',
                        value: totalRevenue,
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                      SummaryItem(
                        label: 'Total Incomes',
                        value: totalIncomes,
                        icon: Icons.trending_up,
                        color: Colors.blue,
                      ),
                      SummaryItem(
                        label: 'Total Expenses',
                        value: totalExpenses,
                        icon: Icons.trending_down,
                        color: Colors.red,
                      ),
                      SummaryItem(
                        label: 'Total Transactions',
                        value: totalTransactions.toDouble(),
                        icon: Icons.receipt_long,
                        color: Colors.purple,
                      ),
                      SummaryItem(
                        label: 'Active Businesses',
                        value: businesses.length.toDouble(),
                        icon: Icons.business,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  
                  // Analytics Section (loaded on demand)
                  if (!areChartsLoaded && !isChartsLoading)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 48,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Revenue Analytics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Load detailed charts and predictions to analyze your business performance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadAnalyticsData,
                            icon: const Icon(Icons.show_chart),
                            label: const Text('Load Analytics'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Charts (shown only after loading)
                  if (areChartsLoaded) ...[
                    MultiSummaryCard(
                      title: 'Detailed Revenue',
                      isLoading: isChartsLoading,
                      items: [
                        SummaryItem(
                          label: 'Monthly Revenue',
                          value: totalMonthlyRevenue,
                          icon: Icons.calendar_month,
                          color: Colors.lightBlue,
                        ),
                        SummaryItem(
                          label: 'Yearly Revenue',
                          value: totalYearlyRevenue,
                          icon: Icons.calendar_today,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    SafeChartContainer(
                      isLoading: isChartsLoading,
                      loadingWidget: const CartesianChartSkeleton(),
                      child: revenueTrendData.isNotEmpty
                          ? CartesianChart(
                              data: revenueTrendData, title: 'Revenue Trend')
                          : const SizedBox.shrink(),
                    ),
                    SafeChartContainer(
                      isLoading: isChartsLoading,
                      loadingWidget: const PieChartSkeleton(),
                      child: revenueDistributionData.length > 1
                          ? PieChart(
                              data: revenueDistributionData,
                              title: 'Revenue Distribution',
                            )
                          : Center(
                              child: Text(
                                  'Add transactions under businesses to see revenue distribution',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 18,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                  textAlign: TextAlign.center),
                            ),
                    ),
                    SafeChartContainer(
                      isLoading: isChartsLoading,
                      loadingWidget: const CartesianChartSkeleton(),
                      child: predictedRevenueData.isNotEmpty
                          ? RevenuePredictionChart(
                              title: 'Revenue Prediction',
                              historicalData: revenueTrendData,
                              predictions: predictedRevenueData)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
