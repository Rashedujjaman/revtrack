// import 'package:flutter/material.dart';
// import 'package:revtrack/models/bank_account_model.dart';
// import 'package:revtrack/services/bank_account_service.dart';
// import 'package:revtrack/services/bank_transfer_service.dart';
// import 'package:intl/intl.dart';

// class BankTransferBottomSheet extends StatefulWidget {
//   final String fromAccountId;
//   final String userId;

//   const BankTransferBottomSheet({
//     super.key,
//     required this.fromAccountId,
//     required this.userId,
//   });

//   @override
//   State<BankTransferBottomSheet> createState() => _BankTransferBottomSheetState();
// }

// class _BankTransferBottomSheetState extends State<BankTransferBottomSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _noteController = TextEditingController();
  
//   List<BankAccount> _availableAccounts = [];
//   BankAccount? _fromAccount;
//   String? _selectedToAccountId;
//   bool _isLoading = false;
//   bool _isTransferring = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAccounts();
//   }

//   Future<void> _loadAccounts() async {
//     setState(() => _isLoading = true);
//     try {
//       final accounts = await BankAccountService().getBankAccountsByUser(widget.userId);
//       _fromAccount = accounts.firstWhere((account) => account.id == widget.fromAccountId);
//       _availableAccounts = accounts.where((account) => account.id != widget.fromAccountId).toList();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading accounts: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _transferMoney() async {
//     if (!_formKey.currentState!.validate() || _selectedToAccountId == null) return;

//     setState(() => _isTransferring = true);
//     try {
//       await BankTransferService().transferMoney(
//         fromAccountId: widget.fromAccountId,
//         toAccountId: _selectedToAccountId!,
//         amount: double.parse(_amountController.text),
//         note: _noteController.text.trim(),
//         userId: widget.userId,
//       );

//       if (mounted) {
//         Navigator.pop(context, true); // Return success
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Transfer completed successfully!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Transfer failed: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isTransferring = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.8,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
          
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//                 const Expanded(
//                   child: Text(
//                     'Transfer Money',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(width: 48), // Balance for the close button
//               ],
//             ),
//           ),

//           if (_isLoading)
//             const Expanded(
//               child: Center(child: CircularProgressIndicator()),
//             )
//           else
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // From Account Card
//                       if (_fromAccount != null) ...[
//                         const Text(
//                           'From Account',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildAccountCard(_fromAccount!, true),
//                         const SizedBox(height: 24),
//                       ],

//                       // To Account Selection
//                       const Text(
//                         'To Account',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                       ),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         value: _selectedToAccountId,
//                         isDense: false,
//                         decoration: const InputDecoration(
//                           hintText: 'Select destination account',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.account_balance),
//                         ),
//                         items: _availableAccounts.map((account) {
//                           return DropdownMenuItem(
//                             value: account.id,
//                             child: Row(
//                               children: [
//                                 // Icon(
//                                 //   account.accountType == AccountType.credit
//                                 //       ? Icons.credit_card
//                                 //       : Icons.account_balance,
//                                 //   size: 20,
//                                 //   color: account.accountType == AccountType.credit
//                                 //       ? Colors.orange
//                                 //       : Colors.blue,
//                                 // ),
//                                 // const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         account.accountName,
//                                         style: const TextStyle(fontSize: 12),
//                                       ),
//                                       Text(
//                                         account.bankName,
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Text(
//                                   NumberFormat.currency(symbol: '৳').format(account.currentBalance),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() => _selectedToAccountId = value);
//                         },
//                         validator: (value) {
//                           if (value == null) return 'Please select a destination account';
//                           return null;
//                         },
//                         isExpanded: true,
//                       ),
//                       const SizedBox(height: 24),

//                       // Amount Field
//                       TextFormField(
//                         controller: _amountController,
//                         decoration: const InputDecoration(
//                           labelText: 'Transfer Amount',
//                           prefixText: '৳ ',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.money),
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter an amount';
//                           }
//                           final amount = double.tryParse(value);
//                           if (amount == null || amount <= 0) {
//                             return 'Enter a valid amount greater than 0';
//                           }
//                           if (_fromAccount != null && amount > _fromAccount!.currentBalance) {
//                             return 'Insufficient balance';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Note Field
//                       TextFormField(
//                         controller: _noteController,
//                         decoration: const InputDecoration(
//                           labelText: 'Note (Optional)',
//                           hintText: 'Add a note for this transfer',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.note),
//                         ),
//                         maxLines: 2,
//                       ),
//                       const SizedBox(height: 32),

//                       // Transfer Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _isTransferring ? null : _transferMoney,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).colorScheme.primary,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: _isTransferring
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : const Text(
//                                   'Transfer Money',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAccountCard(BankAccount account, bool isFromAccount) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isFromAccount 
//             ? Colors.blue.withValues(alpha: 0.1)
//             : Colors.green.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isFromAccount 
//               ? Colors.blue.withValues(alpha: 0.3)
//               : Colors.green.withValues(alpha: 0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             account.accountType == AccountType.credit
//                 ? Icons.credit_card
//                 : Icons.account_balance,
//             color: isFromAccount ? Colors.blue : Colors.green,
//             size: 32,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   account.accountName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   account.bankName,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Balance: ${NumberFormat.currency(symbol: '৳').format(account.currentBalance)}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: isFromAccount ? Colors.blue[700] : Colors.green[700],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }
// }
