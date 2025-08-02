import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/models/bank_account_model.dart';
import 'package:revtrack/services/bank_account_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/widgets/bank_account_card.dart';
import 'package:revtrack/screens/add_bank_account_screen.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:intl/intl.dart';

/// Bank accounts management screen with comprehensive financial overview
/// 
/// Features:
/// - Financial overview cards showing net balance, bank balance, and credit debt
/// - Real-time balance calculations across all account types
/// - Interactive bank account cards with transfer, edit, and delete actions
/// - Account creation and editing through dedicated forms
/// - Skeleton loading states for smooth user experience
/// - Empty state with guided call-to-action for first account
/// - Automatic keep-alive for performance optimization
/// - Comprehensive error handling with user-friendly messages
/// - Integration with BankAccountService for all CRUD operations
class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

/// Stateful widget implementation with financial data management
class _BankAccountsScreenState extends State<BankAccountsScreen>
    with AutomaticKeepAliveClientMixin {
  
  /// Gets current user ID from UserProvider for account operations
  String? get userId => Provider.of<UserProvider>(context, listen: false).userId;
  
  // State management variables
  List<BankAccount> bankAccounts = [];
  bool isLoading = false;
  bool _disposed = false;
  
  // Financial overview calculations
  double netBalance = 0.0;        // Total balance minus credit debt
  double totalBankBalance = 0.0;   // Sum of savings and current accounts
  double totalCreditDebt = 0.0;    // Total outstanding credit card debt

  /// Keeps widget alive during parent rebuilds for better performance
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Loads all bank accounts and calculates financial overview
  /// 
  /// Fetches user's bank accounts and calculates net balance, total bank
  /// balance, and credit debt. Updates UI state and handles errors gracefully.
  /// Includes disposal check to prevent state updates after widget disposal.
  Future<void> _loadBankAccounts() async {
    if (_disposed || userId == null) return;

    setState(() {
      isLoading = true;
      bankAccounts.clear();
    });

    try {
      final accounts = await BankAccountService().getBankAccountsByUser(userId!);
      final netBal = await BankAccountService().calculateNetBalance(userId!);
      final bankBal = await BankAccountService().getTotalBankBalance(userId!);
      final creditDebt = await BankAccountService().getTotalCreditCardDebt(userId!);

      if (!_disposed) {
        setState(() {
          bankAccounts = accounts;
          netBalance = netBal;
          totalBankBalance = bankBal;
          totalCreditDebt = creditDebt;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!_disposed) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading accounts: $e')),
          );
        }
      }
    }
  }

  /// Shows the add account dialog and refreshes list on success
  /// 
  /// Navigates to AddBankAccountScreen for new account creation.
  /// Refreshes the account list if a new account was successfully added.
  Future<void> _showAddAccountDialog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBankAccountScreen(userId: userId!),
      ),
    );

    if (result == true) {
      _loadBankAccounts();
    }
  }

  /// Shows the edit account dialog for the specified account
  /// 
  /// Parameters:
  /// - [account]: BankAccount to edit
  /// 
  /// Navigates to AddBankAccountScreen with existing account data.
  /// Refreshes the account list if account was successfully updated.
  Future<void> _showEditAccountDialog(BankAccount account) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBankAccountScreen(
          userId: userId!,
          accountToEdit: account,
        ),
      ),
    );

    if (result == true) {
      _loadBankAccounts();
    }
  }

  /// Deletes the specified account with confirmation dialog
  /// 
  /// Parameters:
  /// - [account]: BankAccount to delete
  /// 
  /// Shows confirmation dialog before deletion. Performs soft delete
  /// through BankAccountService and refreshes the list on success.
  /// Provides user feedback for both success and error cases.
  Future<void> _deleteAccount(BankAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.accountName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BankAccountService().deleteBankAccount(account.id);
        _loadBankAccounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Overview Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              children: [
                // const Text(
                //   'Balance Overview',
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 8),
                
                // Net Balance Card
                _buildOverviewCard(
                  'Net Balance',
                  netBalance,
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    // Bank Balance Card
                    Expanded(
                      child: _buildBalanceCard(
                        'Bank Balance',
                        totalBankBalance,
                        Colors.green,
                        Icons.account_balance,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Credit Debt Card
                    Expanded(
                      child: _buildBalanceCard(
                        'Credit Debt',
                        totalCreditDebt,
                        Colors.red,
                        Icons.credit_card,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Accounts List
          Expanded(
            child: userId == null
                ? const Center(child: Text('User not logged in'))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Accounts',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: _showAddAccountDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Account'),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: isLoading
                            ? ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 3,
                                itemBuilder: (context, index) => const BankAccountCardSkeleton(),
                              )
                            : bankAccounts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No accounts found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add your first bank account to get started',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          onPressed: _showAddAccountDialog,
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Account'),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: bankAccounts.length,
                                    itemBuilder: (context, index) {
                                      final account = bankAccounts[index];
                                      return BankAccountCard(
                                        account: account,
                                        userId: userId,
                                        onEdit: () => _showEditAccountDialog(account),
                                        onDelete: () => _deleteAccount(account),
                                        onRefresh: _loadBankAccounts,
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'add_bank_account',
      //   onPressed: _showAddAccountDialog,
      //   tooltip: 'Add Account',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  /// Builds overview card for main financial metrics
  /// 
  /// Parameters:
  /// - [title]: Card title (e.g., "Net Balance")
  /// - [amount]: Financial amount to display
  /// - [color]: Theme color for icon and text
  /// - [icon]: Icon to display in the card
  /// 
  /// Returns: Container with formatted financial overview card
  Widget _buildOverviewCard(String title, double amount, Color color, IconData icon) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 30),
          ),

          const SizedBox(width: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              // const SizedBox(height: 4),
              Text(
                NumberFormat.currency(symbol: '৳').format(amount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds compact balance card for secondary metrics
  /// 
  /// Parameters:
  /// - [title]: Card title (e.g., "Bank Balance", "Credit Debt")
  /// - [amount]: Financial amount to display
  /// - [color]: Theme color for icon and text
  /// - [icon]: Icon to display in the card
  /// 
  /// Returns: Container with formatted balance card for side-by-side display
  Widget _buildBalanceCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),

              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
                  
            ],
          ),
          
          Text(
            NumberFormat.currency(symbol: '৳').format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
