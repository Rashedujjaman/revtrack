import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final String id;
  final String businessId;
  final String type;
  final double amount;
  final String category;
  final Timestamp dateCreated;
  final bool isDeleted;

  Record({
    required this.id,
    required this.businessId,
    required this.type,
    required this.amount,
    required this.category,
    required this.dateCreated,
    required this.isDeleted,
  });

  // Factory method to create a Record object from JSON
  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      businessId: json['businessId'],
      type: json['type'],
      amount: json['amount'],
      category: json['category'],
      dateCreated: json['dateCreated'],
      isDeleted: json['isDeleted'] ?? false,
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
      'isDeleted': isDeleted,
    };
  }
}
