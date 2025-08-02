import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service class for managing business-level aggregated statistics
/// 
/// Features:
/// - Real-time business statistics updates using Firestore transactions
/// - Transaction event handlers for maintaining accurate aggregations
/// - Atomic operations to prevent data inconsistency
/// - Business revenue calculation (incomes - expenses)
/// - Transaction count tracking for analytics
/// - One-time initialization for existing businesses (migration support)
/// - Comprehensive error handling with debug logging
/// - Statistics summary retrieval for dashboard displays
class BusinessStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Updates business statistics when a transaction is added
  Future<void> onTransactionAdded({
    required String businessId,
    required String transactionType, // 'income' or 'expense'
    required double amount,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final businessRef = _firestore.collection('Business').doc(businessId);
        final businessDoc = await transaction.get(businessRef);
        
        if (!businessDoc.exists) {
          throw Exception('Business not found');
        }

        final currentData = businessDoc.data()!;
        final currentIncomes = (currentData['incomes'] ?? 0.0).toDouble();
        final currentExpenses = (currentData['expenses'] ?? 0.0).toDouble();
        final currentTransactionsCount = (currentData['transactionsCount'] ?? 0);

        // Update the appropriate field based on transaction type
        if (transactionType.toLowerCase() == 'income') {
          transaction.update(businessRef, {
            'incomes': currentIncomes + amount,
            'transactionsCount': currentTransactionsCount + 1,
            'dateModified': FieldValue.serverTimestamp(),
          });
        } else if (transactionType.toLowerCase() == 'expense') {
          transaction.update(businessRef, {
            'expenses': currentExpenses + amount,
            'transactionsCount': currentTransactionsCount + 1,
            'dateModified': FieldValue.serverTimestamp(),
          });
        }
      });
      
      debugPrint('Business stats updated after transaction added');
    } catch (e) {
      debugPrint('Error updating business stats on transaction add: $e');
      rethrow;
    }
  }

  /// Updates business statistics when a transaction is updated
  Future<void> onTransactionUpdated({
    required String businessId,
    required String oldTransactionType,
    required double oldAmount,
    required String newTransactionType,
    required double newAmount,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final businessRef = _firestore.collection('Business').doc(businessId);
        final businessDoc = await transaction.get(businessRef);
        
        if (!businessDoc.exists) {
          throw Exception('Business not found');
        }

        final currentData = businessDoc.data()!;
        double currentIncomes = (currentData['incomes'] ?? 0.0).toDouble();
        double currentExpenses = (currentData['expenses'] ?? 0.0).toDouble();

        // First, reverse the old transaction
        if (oldTransactionType.toLowerCase() == 'income') {
          currentIncomes -= oldAmount;
        } else if (oldTransactionType.toLowerCase() == 'expense') {
          currentExpenses -= oldAmount;
        }

        // Then apply the new transaction
        if (newTransactionType.toLowerCase() == 'income') {
          currentIncomes += newAmount;
        } else if (newTransactionType.toLowerCase() == 'expense') {
          currentExpenses += newAmount;
        }

        // Update the business document
        transaction.update(businessRef, {
          'incomes': currentIncomes.clamp(0.0, double.infinity), // Ensure non-negative
          'expenses': currentExpenses.clamp(0.0, double.infinity), // Ensure non-negative
          'dateModified': FieldValue.serverTimestamp(),
        });
      });
      
      debugPrint('Business stats updated after transaction modified');
    } catch (e) {
      debugPrint('Error updating business stats on transaction update: $e');
      rethrow;
    }
  }

  /// Updates business statistics when a transaction is deleted
  Future<void> onTransactionDeleted({
    required String businessId,
    required String transactionType,
    required double amount,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final businessRef = _firestore.collection('Business').doc(businessId);
        final businessDoc = await transaction.get(businessRef);
        
        if (!businessDoc.exists) {
          throw Exception('Business not found');
        }

        final currentData = businessDoc.data()!;
        double currentIncomes = (currentData['incomes'] ?? 0.0).toDouble();
        double currentExpenses = (currentData['expenses'] ?? 0.0).toDouble();
        int currentTransactionsCount = (currentData['transactionsCount'] ?? 0);

        // Reverse the transaction
        if (transactionType.toLowerCase() == 'income') {
          currentIncomes -= amount;
        } else if (transactionType.toLowerCase() == 'expense') {
          currentExpenses -= amount;
        }

        // Decrement transaction count
        currentTransactionsCount = (currentTransactionsCount - 1).clamp(0, currentTransactionsCount);

        transaction.update(businessRef, {
          'incomes': currentIncomes.clamp(0.0, double.infinity), // Ensure non-negative
          'expenses': currentExpenses.clamp(0.0, double.infinity), // Ensure non-negative
          'transactionsCount': currentTransactionsCount,
          'dateModified': FieldValue.serverTimestamp(),
        });
      });
      
      debugPrint('Business stats updated after transaction deleted');
    } catch (e) {
      debugPrint('Error updating business stats on transaction delete: $e');
      rethrow;
    }
  }

  /// Initialize business statistics by calculating from existing transactions (one-time migration)
  Future<void> initializeBusinessStats(String businessId) async {
    try {
      final transactionsSnapshot = await _firestore
          .collection('Transaction')
          .where('businessId', isEqualTo: businessId)
          .where('isDeleted', isEqualTo: false)
          .get();

      double totalIncomes = 0.0;
      double totalExpenses = 0.0;
      int transactionsCount = 0;

      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final type = data['type']?.toString().toLowerCase() ?? '';
        final amount = (data['amount'] ?? 0.0).toDouble();

        if (type == 'income') {
          totalIncomes += amount;
        } else if (type == 'expense') {
          totalExpenses += amount;
        }
        transactionsCount++;
      }

      // Update the business document
      await _firestore.collection('Business').doc(businessId).update({
        'incomes': totalIncomes,
        'expenses': totalExpenses,
        'transactionsCount': transactionsCount,
        'dateModified': FieldValue.serverTimestamp(),
      });

      debugPrint('Business stats initialized for business: $businessId');
      debugPrint('Total incomes: $totalIncomes, Total expenses: $totalExpenses, Transactions: $transactionsCount');
    } catch (e) {
      debugPrint('Error initializing business stats: $e');
      rethrow;
    }
  }

  /// Get calculated revenue (incomes - expenses) for a business
  Future<double> getBusinessRevenue(String businessId) async {
    try {
      final businessDoc = await _firestore.collection('Business').doc(businessId).get();
      
      if (!businessDoc.exists) {
        return 0.0;
      }

      final data = businessDoc.data()!;
      final incomes = (data['incomes'] ?? 0.0).toDouble();
      final expenses = (data['expenses'] ?? 0.0).toDouble();
      
      return incomes - expenses;
    } catch (e) {
      debugPrint('Error getting business revenue: $e');
      return 0.0;
    }
  }

  /// Get business statistics summary
  Future<Map<String, dynamic>> getBusinessStatsSummary(String businessId) async {
    try {
      final businessDoc = await _firestore.collection('Business').doc(businessId).get();
      
      if (!businessDoc.exists) {
        return {
          'incomes': 0.0,
          'expenses': 0.0,
          'revenue': 0.0,
          'transactionsCount': 0,
        };
      }

      final data = businessDoc.data()!;
      final incomes = (data['incomes'] ?? 0.0).toDouble();
      final expenses = (data['expenses'] ?? 0.0).toDouble();
      final transactionsCount = data['transactionsCount'] ?? 0;
      final revenue = incomes - expenses;

      return {
        'incomes': incomes,
        'expenses': expenses,
        'revenue': revenue,
        'transactionsCount': transactionsCount,
      };
    } catch (e) {
      debugPrint('Error getting business stats summary: $e');
      return {
        'incomes': 0.0,
        'expenses': 0.0,
        'revenue': 0.0,
        'transactionsCount': 0,
      };
    }
  }
}
