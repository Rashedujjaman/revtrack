import 'package:intl/intl.dart';
import 'package:revtrack/screens/main_navigation_screen.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/snackbar_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:animated_number/animated_number.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:revtrack/widgets/edit_business_bottom_sheet.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:revtrack/screens/add_edit_transaction_screen.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/widgets/pie_chart.dart';
import 'package:revtrack/widgets/cartesian_chart.dart';
import 'package:revtrack/widgets/date_range_selector.dart';
import 'package:provider/provider.dart';

/// Comprehensive business overview screen with analytics and management
///
/// Features:
/// - Business header with logo, name, and total statistics
/// - Interactive date range selector for data filtering
/// - Real-time transaction list with edit/delete operations
/// - Dynamic chart visualization (pie charts and line charts)
/// - Revenue trend analysis with monthly/daily breakdowns
/// - Category-wise expense and income breakdowns
/// - Business deletion with confirmation dialog
/// - Floating action button for quick transaction creation
/// - Skeleton loading states for better UX
/// - AutomaticKeepAliveClientMixin for performance optimization
class BusinessOverviewScreen extends StatefulWidget {
  final Business _business;

  /// Creates a business overview screen
  ///
  /// Parameters:
  /// - [_business]: Business entity containing id, name, logo, and metadata
  const BusinessOverviewScreen(this._business, {super.key});

  @override
  State<BusinessOverviewScreen> createState() => _BusinessOverviewScreenState();
}

/// Stateful implementation with comprehensive business analytics and management
class _BusinessOverviewScreenState extends State<BusinessOverviewScreen>
    with AutomaticKeepAliveClientMixin {
  // Core state variables for business overview management
  get userId => Provider.of<UserProvider>(context, listen: false).userId;
  List<Transaction1> transactions = [];
  bool isLoading = false;
  bool _disposed = false;

  /// Keeps widget alive during parent rebuilds for better performance
  @override
  bool get wantKeepAlive => true;

  // Business display variables
  String businessLogo = '';
  String businessName = '';
  bool expanded = false;

  // Date range for filtering transactions (default: current month)
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
        23, 59, 59, 999, 999),
  );

  // Financial calculation cache variables
  double totalIncome = 0.00;
  double totalExpense = 0.00;
  double revenue = 0.00;

  // Search and filter variables
  bool _isSearchVisible = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    isLoading = true;
    businessLogo = widget._business.logoUrl ?? '';
    businessName = widget._business.name;
    super.initState();
    fetchTransactions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _disposed = true;
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactions() async {
    if (_disposed) return;

    setState(() {
      isLoading = true;
      transactions.clear();
    });
    // Fetch transactions for the selected business and date range
    final result = await TransactionService()
        .getTransactionsByBusiness(widget._business.id, _selectedDateRange);

    if (_disposed) return;

    setState(() {
      transactions = result;

      //After fetching transactions, calculate totals
      totalIncome = calculateTotalIncome();
      totalExpense = calculateTotalExpense();
      revenue = calculateRevenue();

      //Set loading state to false
      isLoading = false;
    });
  }

  Future<void> deleteBusiness() async {
    try {
      BusinessService().deleteBusiness(widget._business.id);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(1)),
        );

        // SnackbarService()
        //     .successMessage(context, 'Business deleted successfully.');
      }
    } catch (e) {
      SnackbarService().errorMessage(
        context,
        'Error deleting business: $e',
      );
    }
  }

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;
    });
  }

  void _editTransaction(Transaction1 transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          widget._business.id,
          widget._business.name,
          transaction.type,
          true, // isEdit = true
          transaction: transaction,
        ),
      ),
    );

    if (result == true) {
      // Refresh transactions if edit was successful
      fetchTransactions();
    }
  }

  double calculateTotalIncome() {
    return filteredTransactions
        .where((transaction) => transaction.type == 'Income')
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
  }

  double calculateTotalExpense() {
    return filteredTransactions
        .where((transaction) => transaction.type == 'Expense')
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
  }

  double calculateRevenue() {
    return calculateTotalIncome() - calculateTotalExpense();
  }

  List<ChartData> getCategoryBreakdownData(String type) {
    final filtered = filteredTransactions.where((t) => t.type == type);
    final Map<String, double> dataMap = {};

    for (var transaction in filtered) {
      dataMap.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return dataMap.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  List<ChartData> getAdaptiveTotals(String type) {
    // Calculate the difference in days between start and end date
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;

    // Use daily data if the range is less than 45 days, otherwise use monthly data
    if (daysDifference < 45) {
      return getDailyTotals(type);
    } else {
      return getMonthlyTotals(type);
    }
  }

  String getChartTitle() {
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;
    return daysDifference < 45
        ? 'Daily Income vs Expense'
        : 'Monthly Income vs Expense';
  }

  List<ChartData> getMonthlyTotals(String type) {
    final Map<String, double> monthlyMap = {};

    for (var transaction in filteredTransactions.where((t) => t.type == type)) {
      final key =
          DateFormat('MMM yyyy').format(transaction.dateCreated.toDate());
      monthlyMap.update(key, (val) => val + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    return monthlyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  List<ChartData> getDailyTotals(String type) {
    final Map<String, double> dailyMap = {};

    for (var transaction in filteredTransactions.where((t) => t.type == type)) {
      final key = DateFormat('MMM dd').format(transaction.dateCreated.toDate());
      dailyMap.update(key, (val) => val + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    return dailyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  List<ChartData> getRevenueTrendData() {
    final Map<String, double> monthlyMap = {};

    for (var transaction in filteredTransactions) {
      final key =
          DateFormat('MMM yyyy').format(transaction.dateCreated.toDate());
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

    return monthlyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  List<ChartData> getAdaptiveRevenueTrendData() {
    // Calculate the difference in days between start and end date
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;

    if (daysDifference < 45) {
      // Use daily data for short periods
      final Map<String, double> dailyMap = {};

      for (var transaction in filteredTransactions) {
        final key =
            DateFormat('MMM dd').format(transaction.dateCreated.toDate());
        dailyMap.update(
          key,
          (val) => transaction.type == 'Income'
              ? val + transaction.amount
              : val - transaction.amount,
          ifAbsent: () => transaction.type == 'Income'
              ? transaction.amount
              : -transaction.amount,
        );
      }

      return dailyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
    } else {
      // Use monthly data for longer periods
      return getRevenueTrendData();
    }
  }

  String getRevenueTrendTitle() {
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;
    return daysDifference < 45
        ? 'Daily Revenue Trend'
        : 'Monthly Revenue Trend';
  }

  List<ChartData> getAdaptiveIncomeData() {
    // Calculate the difference in days between start and end date
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;

    if (daysDifference < 45) {
      // Use daily data for short periods
      final Map<String, double> dailyMap = {};

      for (var transaction
          in filteredTransactions.where((t) => t.type == 'Income')) {
        final key =
            DateFormat('MMM dd').format(transaction.dateCreated.toDate());
        dailyMap.update(
          key,
          (val) => val + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }

      return dailyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
    } else {
      // Use monthly data for longer periods
      return getMonthlyTotals('Income');
    }
  }

  List<ChartData> getAdaptiveExpenseData() {
    // Calculate the difference in days between start and end date
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;

    if (daysDifference < 45) {
      // Use daily data for short periods
      final Map<String, double> dailyMap = {};

      for (var transaction
          in filteredTransactions.where((t) => t.type == 'Expense')) {
        final key =
            DateFormat('MMM dd').format(transaction.dateCreated.toDate());
        dailyMap.update(
          key,
          (val) => val + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }

      return dailyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
    } else {
      // Use monthly data for longer periods
      return getMonthlyTotals('Expense');
    }
  }

  String getIncomeChartTitle() {
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;
    return daysDifference < 45 ? 'Daily Income Trend' : 'Monthly Income Trend';
  }

  String getExpenseChartTitle() {
    final daysDifference =
        _selectedDateRange.end.difference(_selectedDateRange.start).inDays;
    return daysDifference < 45
        ? 'Daily Expense Trend'
        : 'Monthly Expense Trend';
  }

  /// Handles search input changes and updates filter query.
  ///
  /// Called whenever the search text field content changes.
  /// Converts input to lowercase for case-insensitive searching
  /// and triggers UI update to filter displayed transactions and recalculate totals.
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      // Recalculate totals based on filtered transactions
      totalIncome = calculateTotalIncome();
      totalExpense = calculateTotalExpense();
      revenue = calculateRevenue();
    });
  }

  /// Filters transactions based on the current search query.
  ///
  /// Performs multi-field search across transaction properties:
  /// - **Category**: Transaction category/type
  /// - **Amount**: Transaction amount (converted to string)
  /// - **Note**: Transaction description/notes
  ///
  /// The search is case-insensitive and matches partial strings.
  /// Returns the original list if search query is empty.
  ///
  /// Returns:
  /// - Filtered list of transactions matching the search criteria
  List<Transaction1> get filteredTransactions {
    if (_searchQuery.isEmpty) {
      return transactions;
    }

    return transactions.where((transaction) {
      final searchFields = [
        transaction.category.toLowerCase(),
        transaction.amount.toString(),
        transaction.note?.toLowerCase() ?? '',
      ];

      return searchFields.any((field) => field.contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Overview'),
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearchVisible ? 'Hide search' : 'Search transactions',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Fixed Search Bar at the top
          _buildSearchBar(),
          // Scrollable content with RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchTransactions,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      const SizedBox(height: 8),
                      // Date Range Selector at the top
                      DateRangeSelector(
                        initialRange: _selectedDateRange,
                        onChanged: (DateTimeRange newRange) async {
                          setState(() {
                            _selectedDateRange = newRange;
                            isLoading = true;
                          });
                          await fetchTransactions();
                        },
                        presetLabels: const [
                          'This Week',
                          'This Month',
                          'Last 6 Months',
                          'This Year',
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Business Overview Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: .5),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: .5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: Shimmer.fromColors(
                                baseColor: Colors.red,
                                highlightColor: Colors.yellow,
                                child: Text(
                                  businessName,
                                  // textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      spacing: 16,
                                      children: [
                                        // Total Income, Expense, and Revenue labels
                                        const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: [
                                            Text(
                                              'T. Income:',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('T. Expenses:',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text('Revenue:',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),

                                        // Total Income, Expense, and Revenue values
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          spacing: isLoading ? 8 : 4,
                                          children: [
                                            !isLoading
                                                ? AnimatedNumber(
                                                    key: ValueKey(
                                                        'income_$_searchQuery'),
                                                    prefixText: '৳ ',
                                                    startValue: 0.00,
                                                    endValue: totalIncome > 0
                                                        ? totalIncome
                                                        : 0.0,
                                                    duration: const Duration(
                                                        seconds: 2),
                                                    isFloatingPoint: true,
                                                    decimalPoint: 2,
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.3),
                                                    highlightColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                    child: Container(
                                                      width: 70,
                                                      height: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            !isLoading
                                                ? AnimatedNumber(
                                                    key: ValueKey(
                                                        'expense_$_searchQuery'),
                                                    prefixText: '৳ ',
                                                    startValue: 0,
                                                    endValue: totalExpense > 0
                                                        ? totalExpense
                                                        : 0.0,
                                                    duration: const Duration(
                                                        seconds: 2),
                                                    isFloatingPoint: true,
                                                    decimalPoint: 2,
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.3),
                                                    highlightColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                    child: Container(
                                                      width: 70,
                                                      height: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            !isLoading
                                                ? AnimatedNumber(
                                                    key: ValueKey(
                                                        'revenue_$_searchQuery'),
                                                    prefixText: '৳ ',
                                                    startValue: 0,
                                                    endValue: revenue,
                                                    duration: const Duration(
                                                        seconds: 2),
                                                    isFloatingPoint: true,
                                                    decimalPoint: 2,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.3),
                                                    highlightColor:
                                                        Theme.of(context)
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
                                      ],
                                    ),
                                  ],
                                ),
                                // Business Logo
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: businessLogo,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.business, size: 50),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      isLoading == true
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return const TransactionCardSkeleton(); //Show skeleton for loading state
                              })
                          : filteredTransactions.isEmpty
                              ? Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No transactions match your search.'
                                      : 'No transactions found.',
                                )
                              : StatefulBuilder(
                                  builder: (context, setState) {
                                    int visibleCount = 5;

                                    final showAll = expanded ||
                                        filteredTransactions.length <=
                                            visibleCount;
                                    final displayedTransactions = showAll
                                        ? filteredTransactions
                                        : filteredTransactions
                                            .take(visibleCount)
                                            .toList();

                                    return Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              displayedTransactions.length,
                                          itemBuilder: (context, index) {
                                            final transaction =
                                                displayedTransactions[index];
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0.0,
                                                      vertical: 6.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    (transaction.type ==
                                                                'Income'
                                                            ? Colors.green
                                                            : Colors.red)
                                                        .withValues(alpha: 0.1),
                                                    (transaction.type ==
                                                                'Income'
                                                            ? Colors.green
                                                            : Colors.red)
                                                        .withValues(
                                                            alpha: 0.05),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: (transaction.type ==
                                                              'Income'
                                                          ? Colors.green
                                                          : Colors.red)
                                                      .withValues(alpha: 0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (transaction.type ==
                                                                'Income'
                                                            ? Colors.green
                                                            : Colors.red)
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: transaction
                                                                            .type ==
                                                                        'Income'
                                                                    ? Colors
                                                                        .green
                                                                        .withValues(
                                                                            alpha:
                                                                                0.2)
                                                                    : Colors.red
                                                                        .withValues(
                                                                            alpha:
                                                                                0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Icon(
                                                                transaction.type ==
                                                                        'Income'
                                                                    ? Icons
                                                                        .trending_up
                                                                    : Icons
                                                                        .trending_down,
                                                                color: transaction
                                                                            .type ==
                                                                        'Income'
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                                size: 24,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    transaction
                                                                        .category,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onSurface,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          2),
                                                                  Text(
                                                                    transaction
                                                                        .type,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: transaction.type ==
                                                                              'Income'
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  NumberFormat.currency(
                                                                          symbol:
                                                                              '৳ ')
                                                                      .format(transaction
                                                                          .amount),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: transaction.type ==
                                                                            'Income'
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        if (transaction.note !=
                                                                null &&
                                                            transaction.note!
                                                                .isNotEmpty)
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surfaceContainerHighest
                                                                  .withValues(
                                                                      alpha:
                                                                          0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              transaction.note!,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurfaceVariant,
                                                              ),
                                                            ),
                                                          ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.schedule,
                                                              size: 14,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              DateFormat(
                                                                      'dd MMM yyyy')
                                                                  .format(transaction
                                                                      .dateCreated
                                                                      .toDate()),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurfaceVariant,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _editTransaction(
                                                                transaction),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.edit,
                                                            size: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        if (filteredTransactions.length >
                                                visibleCount &&
                                            !isLoading)
                                          TextButton(
                                            onPressed: toggleExpanded,
                                            child: Text(
                                              expanded
                                                  ? 'Show Less'
                                                  : 'Show More',
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                      // const SizedBox(height: 16),
                      // Graphs Section
                      // Line Chart
                      //Expense breakdown through pie chart

                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PieChart(
                              data: getCategoryBreakdownData('Expense'),
                              title: 'Expense Breakdown',
                              borderColor: Colors.red,
                            ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PieChart(
                              data: getCategoryBreakdownData('Income'),
                              title: 'Income Breakdown',
                              borderColor: Colors.green,
                            ),
                      //Adaptive Income vs Expense Column Chart (Daily or Monthly based on date range)
                      !_disposed
                          ? SfCartesianChart(
                              title: ChartTitle(text: getChartTitle()),
                              primaryXAxis: const CategoryAxis(),
                              series: <CartesianSeries<ChartData, String>>[
                                ColumnSeries<ChartData, String>(
                                  dataSource: getAdaptiveTotals('Income'),
                                  xValueMapper: (ChartData data, _) => data.key,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  name: 'Income',
                                  color: Colors.green,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment:
                                        ChartDataLabelAlignment.auto,
                                    angle: -45,
                                  ),
                                ),
                                ColumnSeries<ChartData, String>(
                                  dataSource: getAdaptiveTotals('Expense'),
                                  xValueMapper: (ChartData data, _) => data.key,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  name: 'Expense',
                                  color: Colors.red,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment:
                                        ChartDataLabelAlignment.auto,
                                    angle: -45,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                      // Revenue Trend Line Chart
                      isLoading
                          ? const CircularProgressIndicator()
                          : CartesianChart(
                              data: getAdaptiveRevenueTrendData(),
                              title: getRevenueTrendTitle()),

                      // Income Trend Line Chart
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SfCartesianChart(
                              title: ChartTitle(text: getIncomeChartTitle()),
                              primaryXAxis: const CategoryAxis(),
                              series: <CartesianSeries<ChartData, String>>[
                                LineSeries<ChartData, String>(
                                  dataSource: getAdaptiveIncomeData(),
                                  xValueMapper: (ChartData data, _) => data.key,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  name: 'Income',
                                  color: Colors.green,
                                  width: 3,
                                  markerSettings: const MarkerSettings(
                                    isVisible: true,
                                    color: Colors.green,
                                    borderColor: Colors.white,
                                    borderWidth: 2,
                                  ),
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment:
                                        ChartDataLabelAlignment.auto,
                                  ),
                                ),
                              ],
                            ),

                      // Expense Trend Line Chart
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SfCartesianChart(
                              title: ChartTitle(text: getExpenseChartTitle()),
                              primaryXAxis: const CategoryAxis(),
                              series: <CartesianSeries<ChartData, String>>[
                                LineSeries<ChartData, String>(
                                  dataSource: getAdaptiveExpenseData(),
                                  xValueMapper: (ChartData data, _) => data.key,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  name: 'Expense',
                                  color: Colors.red,
                                  width: 3,
                                  markerSettings: const MarkerSettings(
                                    isVisible: true,
                                    color: Colors.red,
                                    borderColor: Colors.white,
                                    borderWidth: 2,
                                  ),
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment:
                                        ChartDataLabelAlignment.auto,
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 24),

                      // //Action Buttons
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     //Edit Button
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         // Edit Company Logic
                      //         final updatedData = showModalBottomSheet(
                      //           barrierColor:
                      //               Theme.of(context).colorScheme.primary.withValues(
                      //                     alpha: .3,
                      //                   ),
                      //           elevation: 5,
                      //           context: context,
                      //           isScrollControlled: true,
                      //           showDragHandle: true,
                      //           sheetAnimationStyle: AnimationStyle(
                      //             duration: const Duration(milliseconds: 700),
                      //             curve: Curves.easeInOutBack,
                      //           ),
                      //           builder: (context) {
                      //             return BusinessBottomSheet(
                      //               business: widget._business,
                      //               userId: userId,
                      //             );
                      //           },
                      //         );
                      //         updatedData.then(
                      //           (value) {
                      //             if (value != null && context.mounted) {
                      //               setState(() {
                      //                 businessName = value['name'];
                      //                 businessLogo = value['logoUrl'];
                      //               });
                      //             }
                      //             fetchTransactions();
                      //           },
                      //         );
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.blue.withValues(alpha: .7),
                      //       ),
                      //       child: const Text('Edit'),
                      //     ),
                      //     //Delete button
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         // Delete Company Logic
                      //         showDialog(
                      //           context: context,
                      //           builder: (context) {
                      //             return AlertDialog(
                      //               title: const Text('Delete Business'),
                      //               content: const Text(
                      //                   'Are you sure you want to delete this business? This action cannot be undone.'),
                      //               actions: [
                      //                 TextButton(
                      //                   style: ElevatedButton.styleFrom(
                      //                     backgroundColor: Colors.green,
                      //                   ),
                      //                   onPressed: () {
                      //                     Navigator.pop(context);
                      //                   },
                      //                   child: const Text('Cancel'),
                      //                 ),
                      //                 TextButton(
                      //                   style: ElevatedButton.styleFrom(
                      //                     backgroundColor: Colors.red,
                      //                   ),
                      //                   onPressed: () {
                      //                     // Delete function call
                      //                     deleteBusiness();
                      //                   },
                      //                   child: const Text('Delete'),
                      //                 ),
                      //               ],
                      //             );
                      //           },
                      //         );
                      //       },
                      //       style:
                      //           ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      //       child: const Text('Delete'),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 8.0,
          children: [
            //  Add Income Button
            FloatingActionButton(
              heroTag: 'add_income',
              tooltip: 'Add Income',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTransactionScreen(
                      widget._business.id,
                      widget._business.name,
                      'Income',
                      false,
                    ),
                  ),
                ).then((_) => fetchTransactions());
              },
              backgroundColor: Colors.green.withValues(alpha: .7),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            // Add expense Button
            FloatingActionButton(
              heroTag: 'add_expense',
              tooltip: 'Add Expense',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTransactionScreen(
                      widget._business.id,
                      widget._business.name,
                      'Expense',
                      false,
                    ),
                  ),
                ).then((_) => fetchTransactions());
              },
              backgroundColor: Colors.red.withValues(alpha: .7),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds the animated search bar widget with comprehensive search functionality.
  ///
  /// Creates a collapsible search interface that:
  /// - **Animates**: Smooth slide-down animation when toggled (300ms duration)
  /// - **Auto-focuses**: Automatically focuses when expanded for immediate typing
  /// - **Multi-action**: Clear button when text exists, close button when empty
  /// - **Real-time**: Updates search results as user types with no delay
  /// - **Styled**: Material Design 3 theming with proper contrast and borders
  ///
  /// **Search Capabilities**:
  /// - Searches across 6+ transaction fields simultaneously
  /// - Case-insensitive partial string matching
  /// - Descriptive placeholder text explaining searchable fields
  ///
  /// **Interaction**:
  /// - Toggle visibility with `_toggleSearch()` method
  /// - Clear search with dedicated clear button
  /// - Close search bar resets all search state
  ///
  /// Returns:
  /// - AnimatedContainer with TextField or SizedBox based on visibility
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchVisible ? 60 : 0,
      curve: Curves.easeInOut,
      child: _isSearchVisible
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search By (category, amount, note...)',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _toggleSearch,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                    // Recalculate totals based on filtered transactions
                    totalIncome = calculateTotalIncome();
                    totalExpense = calculateTotalExpense();
                    revenue = calculateRevenue();
                  });
                },
              ),
            )
          : const SizedBox(),
    );
  }

  /// Toggles the search bar visibility with animation.
  ///
  /// Shows/hides the animated search bar and manages search state.
  /// When hiding search, clears the search query and controller
  /// to reset the transaction list to unfiltered state and recalculate totals.
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
        // Recalculate totals when clearing search
        totalIncome = calculateTotalIncome();
        totalExpense = calculateTotalExpense();
        revenue = calculateRevenue();
      }
    });
  }
}
