import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/screens/add_edit_transaction_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:intl/intl.dart';
// import 'package:revtrack/services/snackbar_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_number/src/animated_number_widget.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class BusinessOverviewScreen extends StatefulWidget {
  final Business _business;

  const BusinessOverviewScreen(this._business, {super.key});

  @override
  State<BusinessOverviewScreen> createState() => _BusinessOverviewScreenState();
}

class _BusinessOverviewScreenState extends State<BusinessOverviewScreen> {
  List<Transaction1> transactions = [];
  bool isLoading = false;

  bool expanded = false;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, 1, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
        23, 59, 59),
  );

  double totalIncome = 0.00;
  double totalExpense = 0.00;
  double revenue = 0.00;

  @override
  void initState() {
    isLoading = true;
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

  List<_ChartData> getCategoryBreakdownData(String type) {
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
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();
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
            children: [
              const SizedBox(height: 16),
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
                          widget._business.name,
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

                                // Total Income, Expense, and Revenue
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
                            imageUrl: widget._business.logoUrl,
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
                            width: 320,
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
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365 * 5)),
                              lastDate: DateTime.now(),
                              initialDateRange: _selectedDateRange,
                            );
                            if (picked != null &&
                                picked != _selectedDateRange) {
                              setState(() {
                                _selectedDateRange = DateTimeRange(
                                  start: picked.start,
                                  end: picked.end.add(const Duration(
                                      hours: 23, minutes: 59, seconds: 59)),
                                );
                              });
                              await fetchTransactions();
                            }
                          },
                        ),
                  // if (_selectedDateRange != null)
                  //   IconButton(
                  //     icon: const Icon(Icons.clear),
                  //     onPressed: () async {
                  //       setState(() {
                  //         _selectedDateRange = null;
                  //         isLoading = true;
                  //       });
                  //       await fetchTransactions();
                  //     },
                  //   ),
                ],
              ),

              transactions.isEmpty
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
                            isLoading == true
                                ? ListView.builder(
                                    // shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 5,
                                    itemBuilder: (context, index) {
                                      return const TransactionCardSkeleton(); //Show skeleton for loading state
                                    })
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    // padding: const EdgeInsets.symmetric(
                                    //     vertical: 16.0, horizontal: 0.0),
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
                                              color:
                                                  transaction.type == 'Income'
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
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                transaction.category,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          trailing: Text(
                                            '৳ ${transaction.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  transaction.type == 'Income'
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
              const SizedBox(height: 16),
              // Graphs Section
              const Text(
                'Revenue Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Line Chart

              SfCircularChart(
                title: ChartTitle(text: 'Expense Breakdown'),
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: getCategoryBreakdownData('Expense'),
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),

              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: const NumericAxis(),
                  series: <CartesianSeries>[
                    LineSeries<_ChartData, double>(
                      dataSource: [
                        _ChartData('0', 1),
                        _ChartData('1', 3),
                        _ChartData('2', 2),
                        _ChartData('3', 1.5),
                        _ChartData('4', 2.5),
                      ],
                      xValueMapper: (_ChartData data, _) =>
                          double.parse(data.category),
                      yValueMapper: (_ChartData data, _) => data.value,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pie Chart
              SizedBox(
                height: 200,
                child: SfCircularChart(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withValues(alpha: .5),
                  series: <CircularSeries>[
                    PieSeries<_ChartData, String>(
                      dataSource: [
                        _ChartData('Category A', 40),
                        _ChartData('Category B', 30),
                        _ChartData('Category C', 30),
                      ],
                      xValueMapper: (_ChartData data, _) => data.category,
                      yValueMapper: (_ChartData data, _) => data.value,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Bar Chart
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: [
                        _ChartData('A', 5),
                        _ChartData('B', 3),
                        _ChartData('C', 4),
                      ],
                      xValueMapper: (_ChartData data, _) => data.category,
                      yValueMapper: (_ChartData data, _) => data.value,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              //Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Edit Company Logic
                    },
                    child: const Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Delete Company Logic
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
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

class _ChartData {
  final String category;
  final double value;

  _ChartData(this.category, this.value);
}
