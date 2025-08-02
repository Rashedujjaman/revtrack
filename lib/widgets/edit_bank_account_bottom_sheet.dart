// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:revtrack/models/bank_account_model.dart';
// import 'package:revtrack/services/bank_account_service.dart';
// import 'package:revtrack/services/snackbar_service.dart';

// class EditBankAccountBottomSheet extends StatefulWidget {
//   final String userId;
//   final BankAccount? account;

//   const EditBankAccountBottomSheet({
//     super.key,
//     required this.userId,
//     this.account,
//   });

//   @override
//   State<EditBankAccountBottomSheet> createState() => _EditBankAccountBottomSheetState();
// }

// class _EditBankAccountBottomSheetState extends State<EditBankAccountBottomSheet> {
//   final _formKey = GlobalKey<FormState>();
  
//   late final TextEditingController _accountNameController;
//   late final TextEditingController _bankNameController;
//   late final TextEditingController _accountNumberController;
//   late final TextEditingController _currentBalanceController;
//   late final TextEditingController _creditLimitController;
//   late final TextEditingController _descriptionController;
  
//   AccountType _selectedAccountType = AccountType.savings;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize controllers
//     _accountNameController = TextEditingController();
//     _bankNameController = TextEditingController();
//     _accountNumberController = TextEditingController();
//     _currentBalanceController = TextEditingController();
//     _creditLimitController = TextEditingController();
//     _descriptionController = TextEditingController();
    
//     // If editing existing account, populate fields
//     if (widget.account != null) {
//       final account = widget.account!;
//       _accountNameController.text = account.accountName;
//       _bankNameController.text = account.bankName;
//       _accountNumberController.text = account.accountNumber;
//       _currentBalanceController.text = account.currentBalance.toString();
//       _creditLimitController.text = account.creditLimit?.toString() ?? '';
//       _descriptionController.text = account.description ?? '';
//       _selectedAccountType = account.accountType;
//     }
//   }

//   @override
//   void dispose() {
//     _accountNameController.dispose();
//     _bankNameController.dispose();
//     _accountNumberController.dispose();
//     _currentBalanceController.dispose();
//     _creditLimitController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveAccount() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final account = BankAccount(
//         id: widget.account?.id ?? '',
//         userId: widget.userId,
//         accountName: _accountNameController.text.trim(),
//         bankName: _bankNameController.text.trim(),
//         accountNumber: _accountNumberController.text.trim(),
//         accountType: _selectedAccountType,
//         currentBalance: double.parse(_currentBalanceController.text.trim()),
//         creditLimit: _creditLimitController.text.trim().isNotEmpty
//             ? double.parse(_creditLimitController.text.trim())
//             : null,
//         description: _descriptionController.text.trim().isNotEmpty
//             ? _descriptionController.text.trim()
//             : null,
//         dateCreated: widget.account?.dateCreated ?? Timestamp.now(),
//         dateModified: widget.account?.dateModified,
//       );

//       if (widget.account == null) {
//         // Add new account
//         await BankAccountService().addBankAccount(account);
//         if (mounted) {
//           Navigator.pop(context, true);
//           SnackbarService().successMessage(context, 'Account added successfully');
//         }
//       } else {
//         // Update existing account
//         await BankAccountService().updateBankAccount(widget.account!.id, account);
//         if (mounted) {
//           Navigator.pop(context, true);
//           SnackbarService().successMessage(context, 'Account updated successfully');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         SnackbarService().errorMessage(context, 'Error: ${e.toString()}');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isEditing = widget.account != null;
    
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             height: 4,
//             width: 40,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.outline,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
          
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Text(
//                   isEditing ? 'Edit Account' : 'Add New Account',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//           ),
          
//           // Form content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Account Type Selection
//                     const Text(
//                       'Account Type',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
                    
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: theme.colorScheme.outline),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         children: AccountType.values.map((type) {
//                           return RadioListTile<AccountType>(
//                             title: Text(_getAccountTypeLabel(type)),
//                             subtitle: Text(_getAccountTypeDescription(type)),
//                             value: type,
//                             groupValue: _selectedAccountType,
//                             onChanged: (value) {
//                               setState(() => _selectedAccountType = value!);
//                             },
//                           );
//                         }).toList(),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 20),
                    
//                     // Account Name
//                     TextFormField(
//                       controller: _accountNameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Account Name',
//                         hintText: 'e.g., My Checking Account',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter an account name';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Bank Name
//                     TextFormField(
//                       controller: _bankNameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Bank Name',
//                         hintText: 'e.g., Chase Bank',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter the bank name';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Account Number (last 4 digits only)
//                     TextFormField(
//                       controller: _accountNumberController,
//                       decoration: const InputDecoration(
//                         labelText: 'Account Number (Last 4 digits)',
//                         hintText: 'e.g., 1234',
//                         border: OutlineInputBorder(),
//                         prefixText: '**** **** **** ',
//                       ),
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(4),
//                       ],
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter the last 4 digits';
//                         }
//                         if (value.length != 4) {
//                           return 'Please enter exactly 4 digits';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Current Balance
//                     TextFormField(
//                       controller: _currentBalanceController,
//                       decoration: InputDecoration(
//                         labelText: _selectedAccountType == AccountType.credit 
//                             ? 'Current Balance (negative for debt)'
//                             : 'Current Balance',
//                         hintText: _selectedAccountType == AccountType.credit 
//                             ? 'e.g., -500.00' 
//                             : 'e.g., 1000.00',
//                         border: const OutlineInputBorder(),
//                         prefixText: '৳',
//                       ),
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'^\-?[0-9]*\.?[0-9]*')),
//                       ],
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter the current balance';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Please enter a valid amount';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Credit Limit (only for credit cards)
//                     if (_selectedAccountType == AccountType.credit) ...[
//                       TextFormField(
//                         controller: _creditLimitController,
//                         decoration: const InputDecoration(
//                           labelText: 'Credit Limit',
//                           hintText: 'e.g., 5000.00',
//                           border: OutlineInputBorder(),
//                           prefixText: '৳',
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(RegExp(r'[0-9]*\.?[0-9]*')),
//                         ],
//                         validator: (value) {
//                           if (value != null && value.trim().isNotEmpty) {
//                             if (double.tryParse(value) == null) {
//                               return 'Please enter a valid amount';
//                             }
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                     ],
                    
//                     // Description (optional)
//                     TextFormField(
//                       controller: _descriptionController,
//                       decoration: const InputDecoration(
//                         labelText: 'Description (Optional)',
//                         hintText: 'Additional notes about this account',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLines: 3,
//                     ),
                    
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//           ),
          
//           // Save button
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surface,
//               border: Border(
//                 top: BorderSide(color: theme.colorScheme.outlineVariant),
//               ),
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _saveAccount,
//                 child: _isLoading
//                     ? const CircularProgressIndicator()
//                     : Text(isEditing ? 'Update Account' : 'Add Account'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getAccountTypeLabel(AccountType type) {
//     switch (type) {
//       case AccountType.savings:
//         return 'Savings Account';
//       case AccountType.current:
//         return 'Current Account';
//       case AccountType.credit:
//         return 'Credit Card';
//     }
//   }

//   String _getAccountTypeDescription(AccountType type) {
//     switch (type) {
//       case AccountType.savings:
//         return 'For saving money with interest';
//       case AccountType.current:
//         return 'For business transactions';
//       case AccountType.credit:
//         return 'Credit card with credit limit';
//     }
//   }
// }
