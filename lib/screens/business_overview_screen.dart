import 'package:intl/intl.dart';
import 'package:revtrack/screens/main_navigation_screen.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/snackbar_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:animated_number/animated_number.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:revtrack/widgets/edit_business_bottom_sheet.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/models/chart_data_model.dart';
import 'package:revtrack/screens/add_edit_transaction_screen.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/widgets/pie_chart.dart';
import 'package:revtrack/widgets/cartesian_chart.dart';
import 'package:provider/provider.dart';

class BusinessOverviewScreen extends StatefulWidget {
  final Business _business;

  const BusinessOverviewScreen(this._business, {super.key});

  @override
  State<BusinessOverviewScreen> createState() => _BusinessOverviewScreenState();
}

class _BusinessOverviewScreenState extends State<BusinessOverviewScreen> {
  //*************************************************************************************************************************** */
  // Variables for managing business overview state
  get userId => Provider.of<UserProvider>(context, listen: false).userId;
  List<Transaction1> transactions = [];
  bool isLoading = false;
  String businessLogo = '';
  String businessName = '';

  bool expanded = false;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, 1, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
        23, 59, 59, 999, 999),
  );

  double totalIncome = 0.00;
  double totalExpense = 0.00;
  double revenue = 0.00;
  //*************************************************************************************************************************** */

  @override
  void initState() {
    isLoading = true;
    businessLogo = widget._business.logoUrl ?? '';
    businessName = widget._business.name;
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      transactions.clear();
    });
    // Fetch transactions for the selected business and date range
    final result = await TransactionService()
        .getTransactionsByBusiness(widget._business.id, _selectedDateRange);

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

  double calculateTotalIncome() {
    return transactions
        .where((transaction) => transaction.type == 'Income')
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
  }

  double calculateTotalExpense() {
    return transactions
        .where((transaction) => transaction.type == 'Expense')
        .fold(0.00, (sum, transaction) => sum + transaction.amount);
  }

  double calculateRevenue() {
    return calculateTotalIncome() - calculateTotalExpense();
  }

  List<ChartData> getCategoryBreakdownData(String type) {
    final filtered = transactions.where((t) => t.type == type);
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

  List<ChartData> getMonthlyTotals(String type) {
    final Map<String, double> monthlyMap = {};

    for (var transaction in transactions.where((t) => t.type == type)) {
      final key =
          DateFormat('MMM yyyy').format(transaction.dateCreated.toDate());
      monthlyMap.update(key, (val) => val + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    return monthlyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  List<ChartData> getDailyTotals(String type) {
    final Map<String, double> dailyMap = {};

    for (var transaction in transactions.where((t) => t.type == type)) {
      final key = DateFormat('MMM dd').format(transaction.dateCreated.toDate());
      dailyMap.update(key, (val) => val + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    return dailyMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  List<ChartData> getRevenueTrendData() {
    final Map<String, double> monthlyMap = {};

    for (var transaction in transactions) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Overview'),
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4,
            children: [
              const SizedBox(height: 16),
              // Business Overview Card
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
                              fontSize: 24, fontWeight: FontWeight.bold),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 16,
                              children: [
                                // Total Income, Expense, and Revenue labels
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            fontWeight: FontWeight.bold)),
                                    Text('Revenue:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),

                                // Total Income, Expense, and Revenue values
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  spacing: isLoading ? 8 : 4,
                                  children: [
                                    !isLoading
                                        ? AnimatedNumber(
                                            prefixText: '৳ ',
                                            startValue: 0.00,
                                            endValue: totalIncome > 0
                                                ? totalIncome
                                                : 0.0,
                                            duration:
                                                const Duration(seconds: 2),
                                            isFloatingPoint: true,
                                            decimalPoint: 2,
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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
                                    !isLoading
                                        ? AnimatedNumber(
                                            prefixText: '৳ ',
                                            startValue: 0,
                                            endValue: totalExpense > 0
                                                ? totalExpense
                                                : 0.0,
                                            duration:
                                                const Duration(seconds: 2),
                                            isFloatingPoint: true,
                                            decimalPoint: 2,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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
                                    !isLoading
                                        ? AnimatedNumber(
                                            prefixText: '৳ ',
                                            startValue: 0,
                                            endValue: revenue,
                                            duration:
                                                const Duration(seconds: 2),
                                            isFloatingPoint: true,
                                            decimalPoint: 2,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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
              // Date Range Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.5),
                          highlightColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Container(
                            width: 280,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : TextButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            '${DateFormat('dd/MM/yyyy').format(_selectedDateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange.end)}',
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime.now().subtract(
                                        const Duration(days: 365 * 5)),
                                    lastDate: DateTime.now(),
                                    initialDateRange: _selectedDateRange,
                                  );
                                  if (picked != null &&
                                      picked != _selectedDateRange) {
                                    setState(() {
                                      _selectedDateRange = DateTimeRange(
                                        start: picked.start,
                                        end: picked.end.add(const Duration(
                                            hours: 23,
                                            minutes: 59,
                                            seconds: 59)),
                                      );
                                    });
                                    await fetchTransactions();
                                  }
                                },
                        ),
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              _selectedDateRange = DateTimeRange(
                                start: DateTime(DateTime.now().year, 1, 1),
                                end: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    23,
                                    59,
                                    59,
                                    999,
                                    999),
                              );

                              isLoading = true;
                            });
                            await fetchTransactions();
                          },
                  ),
                ],
              ),

              isLoading == true
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const TransactionCardSkeleton(); //Show skeleton for loading state
                      })
                  : transactions.isEmpty
                      ? const Text('No transactions found.')
                      : StatefulBuilder(
                          builder: (context, setState) {
                            int visibleCount = 5;

                            final showAll =
                                expanded || transactions.length <= visibleCount;
                            final displayedTransactions = showAll
                                ? transactions
                                : transactions.take(visibleCount).toList();

                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displayedTransactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction =
                                        displayedTransactions[index];
                                    return Card.outlined(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 0.0, vertical: 4.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: BorderSide(
                                          color: transaction.type == 'Income'
                                              ? Colors.green
                                              : Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      // color: Theme.of(context)
                                      //     .colorScheme
                                      //     .secondary
                                      //     .withValues(alpha: .5),
                                      child: ListTile(
                                        leading: Icon(
                                          transaction.type == 'Income'
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: transaction.type == 'Income'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        title: Text(
                                          transaction.type,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: transaction.type == 'Income'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date: ${DateFormat('dd/MM/yyyy').format(transaction.dateCreated.toDate())}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              transaction.category,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              transaction.note ?? '',
                                            )
                                          ],
                                        ),
                                        trailing: Text(
                                          '৳ ${transaction.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: transaction.type == 'Income'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (transactions.length > visibleCount &&
                                    !isLoading)
                                  TextButton(
                                    onPressed: toggleExpanded,
                                    child: Text(
                                      expanded ? 'Show Less' : 'Show More',
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
              //Monthly Income vs Expense Column Chart
              SfCartesianChart(
                title: const ChartTitle(text: 'Monthly Income vs Expense'),
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: getMonthlyTotals('Income'),
                    xValueMapper: (ChartData data, _) => data.key,
                    yValueMapper: (ChartData data, _) => data.value,
                    name: 'Income',
                    color: Colors.green,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.auto,
                      angle: -45,
                    ),
                  ),
                  ColumnSeries<ChartData, String>(
                    dataSource: getMonthlyTotals('Expense'),
                    xValueMapper: (ChartData data, _) => data.key,
                    yValueMapper: (ChartData data, _) => data.value,
                    name: 'Expense',
                    color: Colors.red,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.auto,
                      angle: -45,
                    ),
                  ),
                ],
              ),
              // Revenue Trend Line Chart
              isLoading
                  ? const CircularProgressIndicator()
                  : CartesianChart(
                      data: getRevenueTrendData(), title: 'Revenue Trend'),
              const SizedBox(height: 24),

              //Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Edit Button
                  ElevatedButton(
                    onPressed: () {
                      // Edit Company Logic
                      final updatedData = showModalBottomSheet(
                        barrierColor:
                            Theme.of(context).colorScheme.primary.withValues(
                                  alpha: .3,
                                ),
                        elevation: 5,
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        sheetAnimationStyle: AnimationStyle(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeInOutBack,
                        ),
                        builder: (context) {
                          return BusinessBottomSheet(
                            business: widget._business,
                            userId: userId,
                          );
                        },
                      );
                      updatedData.then(
                        (value) {
                          if (value != null && context.mounted) {
                            setState(() {
                              businessName = value['name'];
                              businessLogo = value['logoUrl'];
                            });
                          }
                          fetchTransactions();
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: .7),
                    ),
                    child: const Text('Edit'),
                  ),
                  //Delete button
                  ElevatedButton(
                    onPressed: () {
                      // Delete Company Logic
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Business'),
                            content: const Text(
                                'Are you sure you want to delete this business? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  // Delete function call
                                  deleteBusiness();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
