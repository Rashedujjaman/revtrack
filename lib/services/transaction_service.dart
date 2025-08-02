import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:revtrack/services/business_stats_service.dart';
import 'package:revtrack/services/user_stats_service.dart';

/// Service class for managing transaction operations with Firestore
/// Handles CRUD operations for transactions and integrates with business/user stats
class TransactionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final BusinessStatsService _businessStatsService = BusinessStatsService();

  /// Adds a new transaction to Firestore with automatic stats updates
  /// 
  /// Parameters:
  /// - [businessId]: ID of the business this transaction belongs to
  /// - [type]: Transaction type ('Income' or 'Expense')
  /// - [category]: Transaction category
  /// - [amount]: Transaction amount
  /// - [selectedDate]: Transaction date (defaults to now if null)
  /// - [note]: Optional transaction note
  /// - [bankAccountId]: Optional bank account ID for balance tracking
  Future<void> addTransaction(
    String businessId, 
    String type, 
    String category,
    double amount, 
    DateTime? selectedDate, 
    String? note, 
    [String? bankAccountId]
  ) async {
    try {
      final batch = firestore.batch();
      
      // Add the transaction
      final transactionRef = firestore.collection('Transaction').doc();
      batch.set(transactionRef, {
        'businessId': businessId,
        'type': type,
        'amount': amount,
        'category': category,
        'dateCreated': selectedDate ?? DateTime.now(),
        'dateModified': DateTime.now(),
        'isDeleted': false,
        'note': note ?? '',
        'bankAccountId': bankAccountId,
      });
      
      // Update bank account balance if bank account is selected
      if (bankAccountId != null) {
        final bankAccountRef = firestore.collection('BankAccounts').doc(bankAccountId);
        final bankAccountDoc = await bankAccountRef.get();
        
        if (bankAccountDoc.exists) {
          final currentBalance = (bankAccountDoc.data()!['currentBalance'] ?? 0.0) as double;
          double newBalance;
          
          if (type == 'Income') {
            newBalance = currentBalance + amount;
          } else {
            newBalance = currentBalance - amount;
          }
          
          batch.update(bankAccountRef, {
            'currentBalance': newBalance,
            'lastTransactionDate': selectedDate ?? DateTime.now(),
          });
        }
      }
      
      await batch.commit();
      
      // Update business statistics after successful transaction creation
      await _businessStatsService.onTransactionAdded(
        businessId: businessId,
        transactionType: type,
        amount: amount,
      );
      
      // Update user statistics
      final businessDoc = await firestore.collection('Business').doc(businessId).get();
      if (businessDoc.exists) {
        final businessData = businessDoc.data() as Map<String, dynamic>;
        final userId = businessData['userId'] as String;
        
        final transaction = Transaction1(
          businessId: businessId,
          type: type,
          amount: amount,
          category: category,
          dateCreated: Timestamp.fromDate(selectedDate ?? DateTime.now()),
        );
        
        await UserStatsService.onTransactionAdded(userId, transaction);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing transaction with automatic stats adjustments
  /// 
  /// Handles bank account balance reversals and applications for proper accounting
  Future<void> updateTransaction(
    String transactionId,
    String businessId,
    String type,
    String category,
    double amount,
    DateTime selectedDate,
    String note,
    [String? bankAccountId]
  ) async {
    try {
      // Get the existing transaction to check for bank account changes
      final existingTransactionDoc = await firestore.collection('Transaction').doc(transactionId).get();
      final existingTransaction = existingTransactionDoc.exists 
          ? Transaction1.fromDocumentSnapshot(existingTransactionDoc)
          : null;
          
      final batch = firestore.batch();
      
      // Update the transaction
      final transactionRef = firestore.collection('Transaction').doc(transactionId);
      batch.update(transactionRef, {
        'businessId': businessId,
        'type': type,
        'amount': amount,
        'category': category,
        'dateCreated': selectedDate,
        'dateModified': DateTime.now(),
        'note': note,
        'bankAccountId': bankAccountId,
      });
      
      // Handle bank account balance updates
      if (existingTransaction != null) {
        // Reverse the old transaction's impact on the old bank account
        if (existingTransaction.bankAccountId != null) {
          final oldBankAccountRef = firestore.collection('BankAccounts').doc(existingTransaction.bankAccountId!);
          final oldBankAccountDoc = await oldBankAccountRef.get();
          
          if (oldBankAccountDoc.exists) {
            final oldCurrentBalance = (oldBankAccountDoc.data()!['currentBalance'] ?? 0.0) as double;
            double revertedBalance;
            
            // Reverse the old transaction
            if (existingTransaction.type == 'Income') {
              revertedBalance = oldCurrentBalance - existingTransaction.amount;
            } else {
              revertedBalance = oldCurrentBalance + existingTransaction.amount;
            }
            
            batch.update(oldBankAccountRef, {
              'currentBalance': revertedBalance,
              'lastTransactionDate': DateTime.now(),
            });
          }
        }
        
        // Apply the new transaction to the new bank account
        if (bankAccountId != null) {
          final newBankAccountRef = firestore.collection('BankAccounts').doc(bankAccountId);
          final newBankAccountDoc = await newBankAccountRef.get();
          
          if (newBankAccountDoc.exists) {
            final newCurrentBalance = (newBankAccountDoc.data()!['currentBalance'] ?? 0.0) as double;
            double newBalance;
            
            if (type == 'Income') {
              newBalance = newCurrentBalance + amount;
            } else {
              newBalance = newCurrentBalance - amount;
            }
            
            batch.update(newBankAccountRef, {
              'currentBalance': newBalance,
              'lastTransactionDate': selectedDate,
            });
          }
        }
      }
      
      await batch.commit();
      
      // Update business statistics after successful transaction update
      if (existingTransaction != null) {
        await _businessStatsService.onTransactionUpdated(
          businessId: businessId,
          oldTransactionType: existingTransaction.type,
          oldAmount: existingTransaction.amount,
          newTransactionType: type,
          newAmount: amount,
        );
        
        // Update user statistics
        final businessDoc = await firestore.collection('Business').doc(businessId).get();
        if (businessDoc.exists) {
          final businessData = businessDoc.data() as Map<String, dynamic>;
          final userId = businessData['userId'] as String;
          
          final newTransaction = Transaction1(
            businessId: businessId,
            type: type,
            amount: amount,
            category: category,
            dateCreated: Timestamp.fromDate(selectedDate),
          );
          
          await UserStatsService.onTransactionUpdated(userId, existingTransaction, newTransaction);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Soft deletes a transaction (marks as deleted) with automatic stats updates
  /// 
  /// Parameters:
  /// - [uid]: Transaction ID to delete
  Future<void> deleteTransaction(String uid) async {
    try {
      // Get the existing transaction before deleting to update business stats
      final existingTransactionDoc = await firestore.collection('Transaction').doc(uid).get();
      final existingTransaction = existingTransactionDoc.exists 
          ? Transaction1.fromDocumentSnapshot(existingTransactionDoc)
          : null;

      await firestore.collection('Transaction').doc(uid).update({
        'isDeleted': true,
      });

      // Update business statistics after successful transaction deletion
      if (existingTransaction != null) {
        await _businessStatsService.onTransactionDeleted(
          businessId: existingTransaction.businessId,
          transactionType: existingTransaction.type,
          amount: existingTransaction.amount,
        );
        
        // Update user statistics
        final businessDoc = await firestore.collection('Business').doc(existingTransaction.businessId).get();
        if (businessDoc.exists) {
          final businessData = businessDoc.data() as Map<String, dynamic>;
          final userId = businessData['userId'] as String;
          
          await UserStatsService.onTransactionDeleted(userId, existingTransaction);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves all transactions from Firestore
  /// 
  /// Returns a list of all Transaction1 objects
  Future<List<Transaction1>> getAllTransactions() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Transaction').get();
      return snapshot.docs
          .map((doc) => Transaction1.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves transactions for a specific business within a date range
  /// 
  /// Parameters:
  /// - [businessId]: Business ID to filter by
  /// - [dateRange]: Date range to filter transactions
  Future<List<Transaction1>> getTransactionsByBusiness(
    String businessId, 
    DateTimeRange dateRange
  ) async {
    final snapshot = await firestore
        .collection('Transaction')
        .where('businessId', isEqualTo: businessId)
        .where('isDeleted', isEqualTo: false)
        .where('dateCreated', isGreaterThanOrEqualTo: dateRange.start)
        .where('dateCreated', isLessThanOrEqualTo: dateRange.end)
        .orderBy('dateCreated', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Transaction1.fromDocumentSnapshot(doc))
        .toList();
  }

  /// Retrieves all available income categories from Firestore
  /// 
  /// Returns a list of income category names sorted alphabetically
  Future<List<String>> fetchIncomeCategories() async {
    try {
      final snapshot =
          await firestore.collection('IncomeCategory').orderBy('name').get();

      return snapshot.docs
          .map((doc) => doc.data()['name'].toString())
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves all available expense categories from Firestore
  /// 
  /// Returns a list of expense category names sorted alphabetically
  Future<List<String>> fetchExpenseCategories() async {
    try {
      final snapshot =
          await firestore.collection('ExpenseCategory').orderBy('name').get();

      return snapshot.docs
          .map((doc) => doc.data()['name'].toString())
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
