import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/services/transaction_service.dart';
import 'package:revtrack/services/bank_account_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/models/bank_account_model.dart';

/// Screen for adding new transactions or editing existing ones
/// 
/// Features:
/// - Dynamic form for both creating and editing transactions
/// - Category selection based on transaction type (income/expense)
/// - Bank account selection from user's linked accounts
/// - Date picker with default to current date
/// - Form validation with comprehensive error handling
/// - Real-time loading states during submission
/// - Integration with TransactionService for CRUD operations
class AddEditTransactionScreen extends StatefulWidget {
  final String _businessId;
  final String _businessName;
  final String _type;
  final bool _isEdit;
  final Transaction1? transaction; // Optional transaction for editing

  /// Creates a transaction form screen
  /// 
  /// Parameters:
  /// - [_businessId]: Business ID for transaction association
  /// - [_businessName]: Business name for display context
  /// - [_type]: Transaction type ('income' or 'expense')
  /// - [_isEdit]: Whether this is editing an existing transaction
  /// - [transaction]: Existing transaction data when editing
  const AddEditTransactionScreen(
    this._businessId,
    this._businessName,
    this._type,
    this._isEdit, {
    this.transaction,
    super.key,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

/// Stateful widget implementation with form state management
class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  // Form controllers for user input
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Form validation key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form state variables
  String type = '';
  DateTime selectedDate = DateTime.now();
  String selectedCategory = '';
  String? selectedBankAccountId;
  bool _isLoading = false;

  // Data collections
  List<String> _categories = [];
  List<BankAccount> _bankAccounts = [];
  
  /// Gets current user ID from UserProvider
  String? get userId => Provider.of<UserProvider>(context, listen: false).userId;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();
    type = widget._type;

    // If editing, populate fields with existing transaction data
    if (widget._isEdit && widget.transaction != null) {
      final transaction = widget.transaction!;
      amountController.text = transaction.amount.toString();
      selectedDate = transaction.dateCreated.toDate();
      dateController.text = selectedDate.toLocal().toString().split(' ')[0];
      noteController.text = transaction.note ?? '';
      selectedCategory = transaction.category;
      selectedBankAccountId = transaction.bankAccountId;
      type = transaction.type;
    } else {
      dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    }

    fetchCategories();
    _loadBankAccounts();
    // TransactionService().createIncomeAndExpenseCategories();
  }

  Future<void> _loadBankAccounts() async {
    if (userId != null) {
      try {
        final accounts = await BankAccountService().getBankAccountsByUser(userId!);
        setState(() {
          _bankAccounts = accounts;
          
          // Validate selectedBankAccountId exists in current accounts
          if (selectedBankAccountId != null) {
            final accountExists = _bankAccounts.any((account) => account.id == selectedBankAccountId);
            if (!accountExists) {
              selectedBankAccountId = null; // Reset if account no longer exists
            }
          }
        });
      } catch (e) {
        // Handle error silently or show a snackbar
        debugPrint('Error loading bank accounts: $e');
        setState(() {
          _bankAccounts = [];
          selectedBankAccountId = null; // Reset on error
        });
      }
    }
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

      if (widget._isEdit && widget.transaction != null) {
        // Update existing transaction
        final transactionId = widget.transaction!.id;
        if (transactionId != null) {
          await TransactionService().updateTransaction(
            transactionId,
            businessId,
            type,
            category,
            amount,
            selectedDate,
            note,
            selectedBankAccountId,
          );
        } else {
          throw Exception('Transaction ID is null');
        }
      } else {
        // Add new transaction
        await TransactionService().addTransaction(
          businessId,
          type,
          category,
          amount,
          selectedDate,
          note,
          selectedBankAccountId,
        );
      }
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
                        const SizedBox(height: 24.0),
                        
                        // Bank Account Selection
                        _bankAccounts.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.blue[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'No Bank Accounts',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Add bank accounts to track your balances automatically',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                value: selectedBankAccountId,
                                decoration: const InputDecoration(
                                  labelText: 'Bank Account (Optional)',
                                  hintText: 'Select a bank account',
                                  border: OutlineInputBorder(),
                                  // prefixIcon: Icon(Icons.account_balance),
                                  // helperText: 'Select an account to track balance changes',
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Select Bank Account'),
                                  ),
                                  ..._bankAccounts.map((account) {
                                    return DropdownMenuItem<String>(
                                      value: account.id,
                                      child: Container(
                                        constraints: const BoxConstraints(maxWidth: 250),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              account.accountType == AccountType.credit
                                                  ? Icons.credit_card
                                                  : Icons.account_balance,
                                              size: 18,
                                              color: account.accountType == AccountType.credit
                                                  ? Colors.orange
                                                  : Colors.blue,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    account.accountName,
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${account.bankName} • ${account.accountType.name.toUpperCase()}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedBankAccountId = value;
                                  });
                                },
                                validator: null, // Optional field
                                isExpanded: true, // Prevent overflow issues
                                isDense: false,
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
                                    showCheckmark: false,
                                    labelStyle: TextStyle(
                                        color: category == selectedCategory
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary),
                                    label: Text(category),
                                    selected: category == selectedCategory,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedCategory =
                                            selected ? category : '';
                                      });
                                    },
                                    side: category == selectedCategory
                                        ? BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            width: 1.0)
                                        : BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 1.0),
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.8),
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
