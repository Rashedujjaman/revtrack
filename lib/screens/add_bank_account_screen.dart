import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revtrack/models/bank_account_model.dart';
import 'package:revtrack/services/bank_account_service.dart';

/// Screen for adding new bank accounts or editing existing ones
/// 
/// Features:
/// - Dynamic form for creating and editing bank account details
/// - Account type selection (savings, current, credit)
/// - Balance input with proper handling for credit cards
/// - Form validation with comprehensive error messages
/// - Loading states during save operations
/// - Special handling for credit card debt vs available balance
/// - Integration with BankAccountService for CRUD operations
class AddBankAccountScreen extends StatefulWidget {
  final String userId;
  final BankAccount? accountToEdit;

  /// Creates a bank account form screen
  /// 
  /// Parameters:
  /// - [userId]: Current user ID for account association
  /// - [accountToEdit]: Existing account data when editing (null for new account)
  const AddBankAccountScreen({
    super.key,
    required this.userId,
    this.accountToEdit,
  });

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

/// Stateful widget implementation with form state management
class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedAccountType = AccountType.savings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      _populateFields();
    }
  }

  /// Populates form fields with existing account data when editing
  /// 
  /// Handles special cases for credit card balances where debt is stored
  /// as negative values but displayed as positive amounts owed.
  void _populateFields() {
    final account = widget.accountToEdit!;
    _accountNameController.text = account.accountName;
    _bankNameController.text = account.bankName;
    _accountNumberController.text = account.accountNumber;
    
    // For credit cards, show the outstanding balance as positive (what user owes)
    // For other accounts, show actual balance
    if (account.accountType == AccountType.credit && account.currentBalance < 0) {
      _balanceController.text = (-account.currentBalance).toString();
    } else {
      _balanceController.text = account.currentBalance.abs().toString();
    }
    
    _selectedAccountType = account.accountType;
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // For credit cards, store outstanding balance as negative (debt)
      // For savings/current accounts, store as positive (available money)
      double balanceValue = double.parse(_balanceController.text);
      if (_selectedAccountType == AccountType.credit && balanceValue > 0) {
        balanceValue = -balanceValue; // Convert to negative for debt
      }

      final bankAccount = BankAccount(
        id: widget.accountToEdit?.id ?? '',
        userId: widget.userId,
        accountName: _accountNameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        accountType: _selectedAccountType,
        currentBalance: balanceValue,
        dateCreated: widget.accountToEdit?.dateCreated ?? Timestamp.now(),
        dateModified: Timestamp.now(),
      );

      if (widget.accountToEdit != null) {
        await BankAccountService().updateBankAccount(widget.accountToEdit!.id, bankAccount);
      } else {
        await BankAccountService().addBankAccount(bankAccount);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.accountToEdit != null 
                ? 'Account updated successfully!' 
                : 'Account added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountToEdit != null ? 'Edit Account' : 'Add Bank Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: _isLoading ? null : _saveAccount,
        //     child: Text(
        //       'Save',
        //       style: TextStyle(
        //         color: Theme.of(context).colorScheme.primary,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surfaceDim,
                      Theme.of(context).colorScheme.surfaceDim.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.accountToEdit != null ? 'Edit Bank Account' : 'Add New Account',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.accountToEdit != null 
                                ? 'Update your account details'
                                : 'Fill in the details below',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Account Type
              const Text(
                'Account Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: AccountType.values.map((type) {
                    final isSelected = _selectedAccountType == type;
                    final color = type == AccountType.credit
                        ? Colors.orange
                        : type == AccountType.savings
                            ? Colors.green
                            : Colors.blue;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.1) : null,
                        border: type != AccountType.values.last 
                            ? Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              )
                            : null,
                      ),
                      child: RadioListTile<AccountType>(
                        value: type,
                        groupValue: _selectedAccountType,
                        onChanged: (AccountType? value) {
                          if (value != null) {
                            setState(() => _selectedAccountType = value);
                          }
                        },
                        title: Row(
                          children: [
                            Icon(
                              type == AccountType.credit
                                  ? Icons.credit_card
                                  : type == AccountType.savings
                                      ? Icons.savings
                                      : Icons.account_balance,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              type.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? color.shade700 : null,
                              ),
                            ),
                          ],
                        ),
                        activeColor: color,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Account Name
              const Text(
                'Account Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., John Doe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Number
              const Text(
                'Account Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  hintText: 'Last 4 digits. e.g., 1234',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bank Name
              const Text(
                'Bank Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Chase Bank',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Current Balance
              Text(
                _selectedAccountType == AccountType.credit 
                    ? 'Outstanding Balance (Amount You Owe)'
                    : 'Current Balance',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  hintText: _selectedAccountType == AccountType.credit 
                      ? '0.00 (Enter amount you owe)'
                      : '0.00',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.money),
                  prefixText: '৳ ',
                  helperText: _selectedAccountType == AccountType.credit 
                      ? 'Enter 0 if you have no outstanding balance'
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _selectedAccountType == AccountType.credit 
                        ? 'Please enter the outstanding balance'
                        : 'Please enter the current balance';
                  }
                  final balance = double.tryParse(value);
                  if (balance == null || balance < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // const Icon(Icons.save, size: 20),
                            // const SizedBox(width: 8),
                            Text(
                              widget.accountToEdit != null ? 'Update Account' : 'Add Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
