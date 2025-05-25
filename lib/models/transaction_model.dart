import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction1 {
  final String? id;
  final String businessId;
  final String type;
  final double amount;
  final String category;
  final Timestamp dateCreated;
  final Timestamp? dateModified;
  final bool? isDeleted;
  final String? note;

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
  });

  // Factory method to create a Record object from JSON
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
    );
  }

  // Method to convert a Record object to JSON
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
    );
  }
}
