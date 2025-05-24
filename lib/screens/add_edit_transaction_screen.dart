import 'package:flutter/material.dart';
// import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/services/snackbar_service.dart';
// import 'package:revtrack/services/user_provider.dart';
// import 'package:revtrack/services/business_service.dart';
// import 'package:provider/provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final String _businessId;
  final String _businessName;

  const AddEditTransactionScreen(this._businessId, this._businessName,
      {super.key});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();

  bool _isLoading = false;

  List<String> _categories = [];

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();
    dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    fetchCategories();
    _isLoading = false;
  }

  Future<void> fetchCategories() async {
    _categories = await TransactionService().fetchCategories();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction for ${widget._businessName}'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  readOnly: true,
                                  controller: dateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  // readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null &&
                                        picked != selectedDate) {
                                      setState(() {
                                        selectedDate = picked;
                                        dateController.text = selectedDate
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0];
                                      });
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        DropdownButtonFormField(
                          items: const [
                            DropdownMenuItem(
                              value: 'Income',
                              child: Text('Income'),
                            ),
                            DropdownMenuItem(
                              value: 'Expense',
                              child: Text('Expense'),
                            ),
                          ],
                          decoration: const InputDecoration(labelText: 'Type'),
                          value: null,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a type'
                              : null,
                          onChanged: (value) {
                            typeController.text = value ?? '';
                          },
                        ),
                        TextFormField(
                          controller: amountController,
                          decoration:
                              const InputDecoration(labelText: 'Amount'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final n = num.tryParse(value);
                            if (n == null || n <= 0) {
                              return 'Enter a valid number greater than 0';
                            }
                            return null;
                          },
                        ),
                        // DropdownButtonFormField(
                        //   items: _categories.map((category) {
                        //     return DropdownMenuItem(
                        //       value: category,
                        //       child: Text(category),
                        //     );
                        //   }).toList(),
                        //   decoration:
                        //       const InputDecoration(labelText: 'Category'),
                        //   value: null,
                        //   validator: (value) => value == null || value.isEmpty
                        //       ? 'Please select a category'
                        //       : null,
                        //   onChanged: (value) {
                        //     categoryController.text = value ?? '';
                        //   },
                        // ),
                        const SizedBox(height: 16.0),
                        const Text('Select Transaction Category'),

                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            direction: Axis.horizontal,
                            // alignment: WrapAlignment.spaceEvenly,
                            children: _categories.map((category) {
                              final isSelected =
                                  categoryController.text == category;
                              return ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    categoryController.text =
                                        selected ? category : '';
                                  });
                                },
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 50,
          child: ElevatedButton(
            onPressed: () async {
              final String businessId = widget._businessId;
              final String type = typeController.text.trim();
              final double amount = amountController.text.trim().isEmpty
                  ? 0
                  : double.parse(amountController.text.trim());
              final String category = categoryController.text.trim();

              if (_formKey.currentState!.validate() && category.isNotEmpty) {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  await TransactionService().addTransaction(
                    businessId,
                    type,
                    category,
                    amount,
                    selectedDate,
                  );
                  if (context.mounted) {
                    SnackbarService.successMessage(
                      context,
                      'Transaction added successfully',
                    );

                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackbarService.errorMessage(
                      context,
                      'Error adding transaction: $e',
                    );
                  }
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save Transaction'),
          ),
        ),
      ),
    );
  }
}
