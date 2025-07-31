import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revtrack/models/bank_account_model.dart';

class BankAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new bank account
  Future<void> addBankAccount(BankAccount account) async {
    try {
      await _firestore.collection('BankAccounts').doc().set({
        'userId': account.userId,
        'accountName': account.accountName,
        'bankName': account.bankName,
        'accountNumber': account.accountNumber,
        'accountType': account.accountType.toString().split('.').last,
        'currentBalance': account.currentBalance,
        'creditLimit': account.creditLimit,
        'description': account.description,
        'isActive': account.isActive,
        'dateCreated': FieldValue.serverTimestamp(),
        'dateModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get all bank accounts for a user
  Future<List<BankAccount>> getBankAccountsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('BankAccounts')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('dateCreated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BankAccount.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update bank account
  Future<void> updateBankAccount(String accountId, BankAccount account) async {
    try {
      await _firestore.collection('BankAccounts').doc(accountId).update({
        'accountName': account.accountName,
        'bankName': account.bankName,
        'accountNumber': account.accountNumber,
        'accountType': account.accountType.toString().split('.').last,
        'currentBalance': account.currentBalance,
        'creditLimit': account.creditLimit,
        'description': account.description,
        'isActive': account.isActive,
        'dateModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update account balance (called when transactions are added/edited/deleted)
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _firestore.collection('BankAccounts').doc(accountId).update({
        'currentBalance': newBalance,
        'dateModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Soft delete bank account
  Future<void> deleteBankAccount(String accountId) async {
    try {
      await _firestore.collection('BankAccounts').doc(accountId).update({
        'isActive': false,
        'dateModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get a single bank account by ID
  Future<BankAccount?> getBankAccountById(String accountId) async {
    try {
      final doc = await _firestore.collection('BankAccounts').doc(accountId).get();
      if (doc.exists) {
        return BankAccount.fromDocumentSnapshot(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Calculate net balance (total balance - credit card dues)
  Future<double> calculateNetBalance(String userId) async {
    try {
      final accounts = await getBankAccountsByUser(userId);
      double netBalance = 0.0;

      for (var account in accounts) {
        if (account.isCreditCard) {
          // For credit cards, negative balance means debt
          netBalance += account.currentBalance; // This will subtract debt
        } else {
          // For regular accounts, add the balance
          netBalance += account.currentBalance;
        }
      }

      return netBalance;
    } catch (e) {
      rethrow;
    }
  }

  // Get total credit card debt
  Future<double> getTotalCreditCardDebt(String userId) async {
    try {
      final accounts = await getBankAccountsByUser(userId);
      double totalDebt = 0.0;

      for (var account in accounts) {
        if (account.isCreditCard && account.currentBalance < 0) {
          totalDebt += (-account.currentBalance); // Convert to positive
        }
      }

      return totalDebt;
    } catch (e) {
      rethrow;
    }
  }

  // Get total bank balance (excluding credit cards)
  Future<double> getTotalBankBalance(String userId) async {
    try {
      final accounts = await getBankAccountsByUser(userId);
      double totalBalance = 0.0;

      for (var account in accounts) {
        if (!account.isCreditCard) {
          totalBalance += account.currentBalance;
        }
      }

      return totalBalance;
    } catch (e) {
      rethrow;
    }
  }

  // Process transaction impact on bank account
  Future<void> processTransactionImpact({
    required String accountId,
    required double amount,
    required bool isIncome,
  }) async {
    try {
      final account = await getBankAccountById(accountId);
      if (account == null) return;

      double newBalance;
      if (account.isCreditCard) {
        // For credit cards: income reduces debt, expense increases debt
        newBalance = isIncome 
            ? account.currentBalance + amount  // Pay down debt
            : account.currentBalance - amount; // Increase debt
      } else {
        // For regular accounts: income increases balance, expense decreases balance
        newBalance = isIncome 
            ? account.currentBalance + amount
            : account.currentBalance - amount;
      }

      await updateAccountBalance(accountId, newBalance);
    } catch (e) {
      rethrow;
    }
  }

  // Stream for real-time updates
  Stream<List<BankAccount>> streamBankAccountsByUser(String userId) {
    return _firestore
        .collection('BankAccounts')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BankAccount.fromDocumentSnapshot(doc))
            .toList());
  }
}
