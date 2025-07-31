import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revtrack/models/bank_account_model.dart';
import 'package:revtrack/utils/bank_card_designer.dart';
import 'package:revtrack/screens/bank_transfer_screen.dart';

class BankAccountCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;
  final String? userId;

  const BankAccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRefresh,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final isCreditCard = account.accountType == AccountType.credit;
    final bankColors = BankCardDesigner.getBankColors(account.bankName);
    final patternType = BankCardDesigner.getBankPattern(account.bankName);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 185, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bankColors[0],
              bankColors[1],
              bankColors[2],
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: bankColors[0].withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Geometric Pattern Overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BankCardDesigner.createGeometricPattern(
                  bankColors,
                  patternType,
                  const Size(400, 185),
                ),
              ),
            ),
            
            // Glassmorphism overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Account Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20), // Reduced radius
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCreditCard ? Icons.credit_card : Icons.account_balance,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              account.accountType.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Menu Button
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'transfer':
                              if (userId != null) {
                                _showTransferDialog(context);
                              }
                              break;
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (userId != null)
                            const PopupMenuItem(
                              value: 'transfer',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Transfer Money'),
                                ],
                              ),
                            ),
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit Account'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete Account', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                                    
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      // color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'ACCOUNT',
                        //   style: TextStyle(
                        //     color: Colors.white.withValues(alpha: 0.8),
                        //     fontSize: 10,
                        //     fontWeight: FontWeight.bold,
                        //     letterSpacing: 1,
                        //   ),
                        // ),
                        Text(
                          account.accountName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '•••••••••••• ${account.accountNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '${account.bankName.toUpperCase()} Bank',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Bottom Row: Account Number and Balance
                  Container(                           
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                     
                    // Balance with enhanced styling
                    child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   isCreditCard ? 'AVAILABLE' : 'BALANCE',
                          //   style: TextStyle(
                          //     color: Colors.white.withValues(alpha: 0.8),
                          //     fontSize: 10,
                          //     fontWeight: FontWeight.bold,
                          //     letterSpacing: 1,
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(symbol: '৳').format(
                              isCreditCard 
                                ? (account.creditLimit ?? 0) - account.currentBalance.abs()
                                : account.currentBalance
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
            
            // Quick Transfer Floating Button
            if (userId != null)
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => _showTransferDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.swap_horiz,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    if (userId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankTransferScreen(
          fromAccountId: account.id,
          userId: userId!,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the account data if transfer was successful
        onRefresh?.call();
      }
    });
  }
}
