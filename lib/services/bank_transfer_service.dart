import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revtrack/models/bank_account_model.dart';

class BankTransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Transfer money from one bank account to another
  Future<void> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String note,
    required String userId,
  }) async {
    if (fromAccountId == toAccountId) {
      throw Exception('Cannot transfer to the same account');
    }

    if (amount <= 0) {
      throw Exception('Transfer amount must be greater than zero');
    }

    final batch = _firestore.batch();

    try {
      // Get both accounts
      final fromAccountDoc = await _firestore.collection('BankAccounts').doc(fromAccountId).get();
      final toAccountDoc = await _firestore.collection('BankAccounts').doc(toAccountId).get();

      if (!fromAccountDoc.exists) {
        throw Exception('Source account not found');
      }
      if (!toAccountDoc.exists) {
        throw Exception('Destination account not found');
      }

      final fromAccount = BankAccount.fromDocumentSnapshot(fromAccountDoc);
      final toAccount = BankAccount.fromDocumentSnapshot(toAccountDoc);

      // Check if both accounts belong to the user
      if (fromAccount.userId != userId || toAccount.userId != userId) {
        throw Exception('Unauthorized access to accounts');
      }

      // Check if source account has sufficient balance
      if (fromAccount.currentBalance < amount) {
        throw Exception('Insufficient balance in source account');
      }

      // Calculate new balances
      final newFromBalance = fromAccount.currentBalance - amount;
      final newToBalance = toAccount.currentBalance + amount;

      // Update source account
      batch.update(_firestore.collection('BankAccounts').doc(fromAccountId), {
        'currentBalance': newFromBalance,
        'lastTransactionDate': DateTime.now(),
      });

      // Update destination account
      batch.update(_firestore.collection('BankAccounts').doc(toAccountId), {
        'currentBalance': newToBalance,
        'lastTransactionDate': DateTime.now(),
      });

      // Create transfer record
      final transferRecord = {
        'fromAccountId': fromAccountId,
        'fromAccountName': fromAccount.accountName,
        'toAccountId': toAccountId,
        'toAccountName': toAccount.accountName,
        'amount': amount,
        'note': note,
        'userId': userId,
        'transferDate': DateTime.now(),
        'type': 'bank_transfer',
      };

      batch.set(_firestore.collection('BankTransfers').doc(), transferRecord);

      // Commit all changes
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Get transfer history for a user
  Future<List<Map<String, dynamic>>> getTransferHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('BankTransfers')
          .where('userId', isEqualTo: userId)
          .orderBy('transferDate', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
