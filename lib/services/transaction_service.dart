import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revtrack/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Add transaction
  Future<void> addTransaction(String businessId, String type, String category,
      double amount, DateTime? selectedDate) async {
    try {
      await firestore.collection('Transaction').doc().set({
        'businessId': businessId,
        'type': type,
        'amount': amount,
        'category': category,
        'dateCreated': selectedDate ?? DateTime.now(),
        'dateModified': DateTime.now(),
        'isDeleted': false,
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
      String businessId) async {
    final snapshot = await firestore
        .collection('Transaction')
        .where('businessId', isEqualTo: businessId)
        .get();

    return snapshot.docs
        .map((doc) => Transaction1.fromDocumentSnapshot(doc))
        .toList();
  }

  //Fetch categories
  Future<List<String>> fetchCategories() async {
    try {
      final snapshot = await firestore.collection('Category').get();

      return snapshot.docs
          .map((doc) => doc.data()['name'].toString())
          .toSet()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
