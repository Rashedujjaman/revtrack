import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/business_model.dart';
import '../models/transaction_model.dart';

/// Service for managing user-level aggregated statistics
/// 
/// Maintains real-time user stats in ApplicationUsers collection for:
/// - Total businesses count
/// - Total revenue across all businesses
/// - Total transactions count
/// - Total incomes and expenses
/// 
/// Provides instant dashboard loading by avoiding expensive cross-collection queries
class UserStatsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Updates user stats when a business is added
  /// 
  /// Parameters:
  /// - [userId]: User ID to update stats for
  /// - [business]: Business object that was added
  static Future<void> onBusinessAdded(String userId, Business business) async {
    try {
      final userRef = _firestore.collection('ApplicationUsers').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final currentBusinesses = userData['totalBusinesses'] ?? 0;
          
          transaction.update(userRef, {
            'totalBusinesses': currentBusinesses + 1,
          });
        }
      });
    } catch (e) {
      print('Error updating user stats on business added: $e');
      rethrow;
    }
  }

  /// Updates user stats when a business is deleted
  /// 
  /// Parameters:
  /// - [userId]: User ID to update stats for
  static Future<void> onBusinessDeleted(String userId) async {
    try {
      final userRef = _firestore.collection('ApplicationUsers').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final currentBusinesses = userData['totalBusinesses'] ?? 0;
          
          transaction.update(userRef, {
            'totalBusinesses': (currentBusinesses - 1).clamp(0, double.infinity).toInt(),
          });
        }
      });
      
      // Recalculate user stats after business deletion to ensure accuracy
      await initializeUserStats(userId);
    } catch (e) {
      print('Error updating user stats on business deleted: $e');
      rethrow;
    }
  }

  /// Update user stats when a transaction is added
  static Future<void> onTransactionAdded(String userId, Transaction1 transactionModel) async {
    try {
      final userRef = _firestore.collection('ApplicationUsers').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final currentRevenue = (userData['totalRevenue'] ?? 0.0).toDouble();
          final currentTransactions = userData['totalTransactions'] ?? 0;
          final currentIncomes = (userData['totalIncomes'] ?? 0.0).toDouble();
          final currentExpenses = (userData['totalExpenses'] ?? 0.0).toDouble();
          
          final amount = transactionModel.amount;
          
          Map<String, dynamic> updates = {
            'totalTransactions': currentTransactions + 1,
          };
          
          if (transactionModel.type == 'Income') {
            updates['totalRevenue'] = currentRevenue + amount;
            updates['totalIncomes'] = currentIncomes + amount;
          } else if (transactionModel.type == 'Expense') {
            updates['totalRevenue'] = currentRevenue - amount;
            updates['totalExpenses'] = currentExpenses + amount;
          }
          
          transaction.update(userRef, updates);
        }
      });
    } catch (e) {
      print('Error updating user stats on transaction added: $e');
      rethrow;
    }
  }

  /// Update user stats when a transaction is updated
  static Future<void> onTransactionUpdated(String userId, Transaction1 oldTransaction, Transaction1 newTransaction) async {
    try {
      final userRef = _firestore.collection('ApplicationUsers').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        final userData = userDoc.exists ? userDoc.data()! : <String, dynamic>{};
        final currentRevenue = (userData['totalRevenue'] ?? 0.0).toDouble();
        final currentIncomes = (userData['totalIncomes'] ?? 0.0).toDouble();
        final currentExpenses = (userData['totalExpenses'] ?? 0.0).toDouble();
        
        double revenueChange = 0.0;
        double incomesChange = 0.0;
        double expensesChange = 0.0;
        
        // Subtract old transaction effects
        if (oldTransaction.type == 'Income') {
          revenueChange -= oldTransaction.amount;
          incomesChange -= oldTransaction.amount;
        } else if (oldTransaction.type == 'Expense') {
          revenueChange += oldTransaction.amount;
          expensesChange -= oldTransaction.amount;
        }
        
        // Add new transaction effects
        if (newTransaction.type == 'Income') {
          revenueChange += newTransaction.amount;
          incomesChange += newTransaction.amount;
        } else if (newTransaction.type == 'Expense') {
          revenueChange -= newTransaction.amount;
          expensesChange += newTransaction.amount;
        }
        
        transaction.set(userRef, {
          'totalRevenue': currentRevenue + revenueChange,
          'totalIncomes': currentIncomes + incomesChange,
          'totalExpenses': currentExpenses + expensesChange,
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error updating user stats on transaction updated: $e');
      rethrow;
    }
  }

  /// Update user stats when a transaction is deleted
  static Future<void> onTransactionDeleted(String userId, Transaction1 transactionModel) async {
    try {
      final userRef = _firestore.collection('ApplicationUsers').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final currentRevenue = (userData['totalRevenue'] ?? 0.0).toDouble();
          final currentTransactions = userData['totalTransactions'] ?? 0;
          final currentIncomes = (userData['totalIncomes'] ?? 0.0).toDouble();
          final currentExpenses = (userData['totalExpenses'] ?? 0.0).toDouble();
          
          final amount = transactionModel.amount;
          
          Map<String, dynamic> updates = {
            'totalTransactions': (currentTransactions - 1).clamp(0, double.infinity).toInt(),
          };
          
          if (transactionModel.type == 'Income') {
            updates['totalRevenue'] = (currentRevenue - amount).clamp(0.0, double.infinity);
            updates['totalIncomes'] = (currentIncomes - amount).clamp(0.0, double.infinity);
          } else if (transactionModel.type == 'Expense') {
            updates['totalRevenue'] = currentRevenue + amount;
            updates['totalExpenses'] = (currentExpenses - amount).clamp(0.0, double.infinity);
          }
          
          transaction.update(userRef, updates);
        }
      });
    } catch (e) {
      print('Error updating user stats on transaction deleted: $e');
      rethrow;
    }
  }

  /// Initialize user stats for existing users (migration purpose)
  static Future<void> initializeUserStats(String userId) async {
    try {
      // Get all businesses for this user
      final businessesSnapshot = await _firestore
          .collection('Business')
          .where('userId', isEqualTo: userId)
          .get();
      
      int totalBusinesses = businessesSnapshot.docs.length;
      double totalRevenue = 0.0;
      int totalTransactions = 0;
      double totalIncomes = 0.0;
      double totalExpenses = 0.0;
      
      // Calculate totals from all businesses
      for (var businessDoc in businessesSnapshot.docs) {
        final businessData = businessDoc.data();
        double businessIncomes = (businessData['incomes'] ?? 0.0).toDouble();
        double businessExpenses = (businessData['expenses'] ?? 0.0).toDouble();
        int businessTransactionCount = (businessData['transactionsCount'] ?? 0) as int;
        
        totalIncomes += businessIncomes;
        totalExpenses += businessExpenses;
        totalTransactions += businessTransactionCount;
        totalRevenue += (businessIncomes - businessExpenses);
      }
      
      // Update user document with calculated stats
      await _firestore.collection('ApplicationUsers').doc(userId).update({
        'totalBusinesses': totalBusinesses,
        'totalRevenue': totalRevenue,
        'totalTransactions': totalTransactions,
        'totalIncomes': totalIncomes,
        'totalExpenses': totalExpenses,
      });
      
      print('User stats initialized for user: $userId');
    } catch (e) {
      print('Error initializing user stats: $e');
      rethrow;
    }
  }

  /// Get user stats directly from user document
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('ApplicationUsers').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return {
          'totalBusinesses': userData['totalBusinesses'] ?? 0,
          'totalRevenue': (userData['totalRevenue'] ?? 0.0).toDouble(),
          'totalTransactions': userData['totalTransactions'] ?? 0,
          'totalIncomes': (userData['totalIncomes'] ?? 0.0).toDouble(),
          'totalExpenses': (userData['totalExpenses'] ?? 0.0).toDouble(),
        };
      }
      
      return {
        'totalBusinesses': 0,
        'totalRevenue': 0.0,
        'totalTransactions': 0,
        'totalIncomes': 0.0,
        'totalExpenses': 0.0,
      };
    } catch (e) {
      // Log error in debug mode only
      if (kDebugMode) {
        print('Error getting user stats: $e');
      }
      return {
        'totalBusinesses': 0,
        'totalRevenue': 0.0,
        'totalTransactions': 0,
        'totalIncomes': 0.0,
        'totalExpenses': 0.0,
      };
    }
  }
}
