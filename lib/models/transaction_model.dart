import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction model representing financial transactions
/// 
/// Supports both income and expense transactions with:
/// - Business association and categorization
/// - Bank account integration for balance tracking
/// - Audit trail with creation and modification timestamps
/// - Soft delete support with isDeleted flag
/// - Optional notes for transaction details
/// 
/// Used for financial tracking and business statistics calculation
class Transaction1 {
  final String? id;
  final String businessId;
  final String type; // 'Income' or 'Expense'
  final double amount;
  final String category;
  final Timestamp dateCreated;
  final Timestamp? dateModified;
  final bool? isDeleted;
  final String? note;
  final String? bankAccountId; // Optional bank account association

  Transaction1({
    this.id,
    required this.businessId,
    required this.type,
    required this.amount,
    required this.category,
    required this.dateCreated,
    this.dateModified,
    this.isDeleted,
    this.note,
    this.bankAccountId,
  });

  /// Creates Transaction1 object from JSON/Map data
  /// 
  /// Parameters:
  /// - [json]: Map containing transaction data
  /// 
  /// Returns Transaction1 with default values for missing fields
  factory Transaction1.fromJson(Map<String, dynamic> json) {
    return Transaction1(
      id: json['id'],
      businessId: json['businessId'],
      type: json['type'],
      amount: json['amount'],
      category: json['category'],
      dateCreated: json['dateCreated'],
      dateModified: json['dateModified'],
      isDeleted: json['isDeleted'] ?? false,
      note: json['note'],
      bankAccountId: json['bankAccountId'],
    );
  }

  /// Converts Transaction1 object to JSON/Map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'type': type,
      'amount': amount,
      'category': category,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
      'isDeleted': isDeleted,
      'note': note,
      'bankAccountId': bankAccountId,
    };
  }

  factory Transaction1.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction1(
      id: doc.id,
      businessId: data['businessId'],
      type: data['type'],
      amount: data['amount'] is int
          ? (data['amount'] as int).toDouble()
          : data['amount'],
      category: data['category'],
      dateCreated: data['dateCreated'],
      dateModified: data['dateModified'],
      isDeleted: data['isDeleted'] ?? false,
      note: data['note'],
      bankAccountId: data['bankAccountId'],
    );
  }
}
