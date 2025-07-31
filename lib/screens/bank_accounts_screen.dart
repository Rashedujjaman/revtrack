import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/models/bank_account_model.dart';
import 'package:revtrack/services/bank_account_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/widgets/bank_account_card.dart';
import 'package:revtrack/screens/add_bank_account_screen.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:intl/intl.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen>
    with AutomaticKeepAliveClientMixin {
  
  String? get userId => Provider.of<UserProvider>(context, listen: false).userId;
  
  List<BankAccount> bankAccounts = [];
  bool isLoading = false;
  bool _disposed = false;
  
  double netBalance = 0.0;
  double totalBankBalance = 0.0;
  double totalCreditDebt = 0.0;

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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Balance Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildOverviewCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          
          Text(
            NumberFormat.currency(symbol: '৳').format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
