import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/models/business_model.dart';
// import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class BusinessOverviewScreen extends StatelessWidget {
  final Business _business;

  BusinessOverviewScreen(this._business, {super.key});

  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'Income',
      'amount': 100000.00,
      'category': 'Sales',
      'date': '2023-10-01',
    },
    {
      'type': 'Expense',
      'amount': 5000.00,
      'category': 'Marketing',
      'date': '2023-10-02',
    },
    {
      'type': 'Income',
      'amount': 500000.00,
      'category': 'Sales',
      'date': '2023-10-03',
    },
    {
      'type': 'Expense',
      'amount': 300000.00,
      'category': 'Employee Salaries',
      'date': '2023-10-04',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Business Logo
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_business.logoUrl),
              ),
              const SizedBox(height: 10),
              // Business Description
              Text(
                _business.name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withValues(alpha: .5),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        transaction['type'] == 'Income'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction['type'] == 'Income'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                        transaction['type'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction['type'] == 'Income'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${transaction['date']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${transaction['category']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '৳${transaction['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Buttons
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         // Add Expense Logic
              //       },
              //       child: const Text('Add Expense'),
              //     ),
              //     ElevatedButton(
              //       onPressed: () {
              //         // Add Income Logic
              //       },
              //       child: const Text('Add Income'),
              //     ),
              //   ],
              // ),

              const SizedBox(height: 24),
              // Graphs Section
              const Text(
                'Revenue Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),
              // Line Chart
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        onPressed: () {
          // Add Logic
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // floatingActionButton: ExpandableFab(
      //   distance: 80.0,
      //   type: ExpandableFabType.up,
      //   children: [
      //     FloatingActionButton(
      //       tooltip: 'Add Inward Record',
      //       onPressed: () {
      //         debugPrint("Add Inward Record");
      //       },
      //       child: const Icon(Icons.arrow_downward),
      //     ),
      //     FloatingActionButton(
      //       tooltip: 'Add Outward Record',
      //       onPressed: () {
      //         debugPrint("Add Outward Record");
      //       },
      //       child: const Icon(Icons.arrow_upward),
      //     ),
      //   ],
      // ),
    );
  }
}

class _ChartData {
  final String category;
  final double value;

  _ChartData(this.category, this.value);
}
