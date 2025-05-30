import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String id;
  final String name;
  final String? logoUrl;
  final String userId;
  final Timestamp dateCreated;
  final bool? isDeleted;

  Business({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.userId,
    required this.dateCreated,
    this.isDeleted,
  });

  // Factory method to create a Business object from JSON
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      userId: json['userId'],
      dateCreated: json['dateCreated'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // Method to convert a Business object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'userId': userId,
      'dateCreated': dateCreated,
      'isDeleted': isDeleted,
    };
  }

  factory Business.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Business(
      id: doc.id,
      name: data['name'],
      logoUrl: data['logoUrl'],
      userId: data['userId'],
      dateCreated: data['dateCreated'],
      isDeleted: data['isDeleted'] ?? false,
    );
  }
}
