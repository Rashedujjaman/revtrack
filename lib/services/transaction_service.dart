import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revtrack/models/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Add transaction
  Future<void> addTransaction(String businessId, String type, String category,
      double amount, DateTime? selectedDate, String? note) async {
    try {
      await firestore.collection('Transaction').doc().set({
        'businessId': businessId,
        'type': type,
        'amount': amount,
        'category': category,
        'dateCreated': selectedDate ?? DateTime.now(),
        'dateModified': DateTime.now(),
        'isDeleted': false,
        'note': note ?? '',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update transaction
  Future<void> updateTransaction(Transaction1 transaction, String uid) async {
    try {
      await firestore.collection('Transaction').doc(uid).update({
        'type': transaction.type,
        'amount': transaction.amount,
        'category': transaction.category,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String uid) async {
    try {
      await firestore.collection('Transaction').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get all transactions
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllTransactions() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Transaction').get();
      return snapshot.docs;
    } catch (e) {
      rethrow;
    }
  }

  // Get transactions by business ID
  Future<List<Transaction1>> getTransactionsByBusiness(
      String businessId, DateTimeRange dateRange) async {
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

  //Fetch income categories
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

  //Fetch income categories
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

  // Future<void> createIncomeAndExpenseCategories() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //   // Suggested categories
  //   final List<String> incomeCategories = [
  //     'Sales',
  //     'Service',
  //     'Consulting',
  //     'Investment',
  //     'Interest',
  //     'Rental',
  //     'Grants',
  //     'Commission',
  //     'Refunds',
  //     'Donations',
  //   ];

  //   final List<String> expenseCategories = [
  //     'Rent',
  //     'Utilities',
  //     'Salaries',
  //     'Marketing',
  //     'Travel',
  //     'Meals',
  //     'Entertainment',
  //     'Supplies',
  //     'Software',
  //     'Internet',
  //     'Phone',
  //     'Insurance',
  //     'Taxes',
  //     'Maintenance',
  //     'Bank Fees',
  //     'Loan',
  //     'Training',
  //     'Charity',
  //     'Licenses',
  //     'Medical',
  //     'Transportation',
  //     'Fuel',
  //     'Education',
  //   ];

  //   try {
  //     // Batch write for efficiency
  //     WriteBatch batch = firestore.batch();

  //     for (String category in incomeCategories) {
  //       final docRef = firestore.collection('IncomeCategory').doc();
  //       batch.set(docRef, {'name': category});
  //     }

  //     for (String category in expenseCategories) {
  //       final docRef = firestore.collection('ExpenseCategory').doc();
  //       batch.set(docRef, {'name': category});
  //     }

  //     await batch.commit();
  //     print('Income and Expense categories created successfully.');
  //   } catch (e) {
  //     print('Error creating categories: $e');
  //     rethrow;
  //   }
  // }
}
