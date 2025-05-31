import 'package:flutter/material.dart';
import 'package:revtrack/services/transaction_service.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final String _businessId;
  final String _businessName;
  final String _type;
  final bool _isEdit;

  const AddEditTransactionScreen(
      this._businessId, this._businessName, this._type, this._isEdit,
      {super.key});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  //*************************************************************************************************************************** */
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Global key for the form
  // This key will be used to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String type = '';
  DateTime selectedDate = DateTime.now();
  String selectedCategory = '';

  bool _isLoading = false;

  List<String> _categories = [];
  //*************************************************************************************************************************** */

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();
    type = widget._type;
    dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    fetchCategories();
    // TransactionService().createIncomeAndExpenseCategories();
  }

  Future<void> fetchCategories() async {
    _categories = type == 'Income'
        ? await TransactionService().fetchIncomeCategories()
        : await TransactionService().fetchExpenseCategories();
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> saveTransaction() async {
    final String businessId = widget._businessId;
    final double amount = double.parse(amountController.text.trim());
    final String category = selectedCategory.trim();
    final String note = noteController.text.trim();
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
        note,
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction', textAlign: TextAlign.center),
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16.0),
                        Text(
                          '${widget._isEdit ? (type == 'Income' ? 'Edit Income for ' : 'Edit Expense for ') : (type == 'Income' ? 'Add Income for ' : 'Add Expense for ')}${widget._businessName}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16.0),
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
                        const SizedBox(height: 24.0),
                        TextFormField(
                          controller: amountController,
                          decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder()),
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
                        const SizedBox(height: 24.0),
                        TextFormField(
                          controller: noteController,
                          decoration: const InputDecoration(
                            labelText: 'Note (Optional)',
                            hintText: 'Add a note about this transaction',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Text('Select Transaction Category',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _categories.isNotEmpty
                            ? Wrap(
                                spacing: 5.0,
                                runSpacing: 5.0,
                                alignment: WrapAlignment.spaceBetween,
                                runAlignment: WrapAlignment.start,
                                direction: Axis.horizontal,
                                children: List<Widget>.generate(
                                    _categories.length, (int index) {
                                  final String category = _categories[index];
                                  return ChoiceChip(
                                    label: Text(category),
                                    selected: category == selectedCategory,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedCategory =
                                            selected ? category : '';
                                      });
                                    },
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  );
                                }).toList(),
                              )
                            : Text('No categories available',
                                style: Theme.of(context).textTheme.bodyMedium),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _isLoading == true ||
                      selectedCategory.trim().isEmpty ||
                      type.trim().isEmpty ||
                      amountController.text.trim().isEmpty
                  ? null
                  : () async {
                      final success = await saveTransaction();
                      if (context.mounted) {
                        if (success) {
                          // SnackbarService.successMessage(
                          //     context, 'Transaction added successfully');
                          AlertDialog(
                            title: const Text('Success'),
                            content:
                                const Text('Transaction added successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                          Navigator.pop(context);
                        } else {
                          AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Failed to save transaction. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                          // SnackbarService.errorMessage(
                          //     context, 'Failed to save transaction');
                        }
                      }
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Save Transaction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
        ),
      ),
    );
  }
}
