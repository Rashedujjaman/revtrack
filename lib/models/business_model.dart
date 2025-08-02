import 'package:cloud_firestore/cloud_firestore.dart';

/// Business model representing business entities and their aggregated statistics
/// 
/// Contains business information and real-time aggregated financial data:
/// - Basic business details (name, logo, owner, creation date)
/// - Aggregated statistics (incomes, expenses, transaction count)
/// - Soft delete support with isDeleted flag
/// 
/// Used for business management and instant dashboard statistics display
class Business {
  final String id;
  final String name;
  final String? logoUrl;
  final String userId;
  final Timestamp dateCreated;
  final bool? isDeleted;
  
  // Aggregated financial statistics
  final double? incomes;
  final double? expenses;
  final int? transactionsCount;

  Business({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.userId,
    required this.dateCreated,
    this.isDeleted,
    this.incomes,
    this.expenses,
    this.transactionsCount,
  });

  /// Creates Business object from JSON/Map data
  /// 
  /// Parameters:
  /// - [json]: Map containing business data
  /// 
  /// Returns Business with default values for missing fields
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      userId: json['userId'],
      dateCreated: json['dateCreated'],
      isDeleted: json['isDeleted'] ?? false,
      incomes: (json['incomes'] ?? 0.0).toDouble(),
      expenses: (json['expenses'] ?? 0.0).toDouble(),
      transactionsCount: json['transactionsCount'] ?? 0,
    );
  }

  /// Converts Business object to JSON/Map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'userId': userId,
      'dateCreated': dateCreated,
      'isDeleted': isDeleted,
      'incomes': incomes,
      'expenses': expenses,
      'transactionsCount': transactionsCount,
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
      incomes: data['incomes'] is int
          ? (data['incomes'] as int).toDouble()
          : data['incomes']?.toDouble(),
      expenses: data['expenses'] is int

          ? (data['expenses'] as int).toDouble()
          : data['expenses']?.toDouble(),
      transactionsCount: data['transactionsCount'] ?? 0,
    );
  }
}
