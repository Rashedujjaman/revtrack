import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing user data and aggregated statistics
/// 
/// Contains both basic user information and real-time aggregated stats:
/// - Personal details (name, email, phone, etc.)
/// - Business statistics (total businesses, revenue, transactions)
/// - Role-based access control information
/// 
/// Used for instant dashboard loading and user management
class UserModel {
  final String uid;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? imageUrl;
  final bool? isActive;
  
  // Aggregated statistics for instant dashboard loading
  final int? totalBusinesses;
  final double? totalRevenue;
  final int? totalTransactions;
  final double? totalIncomes;
  final double? totalExpenses;
  
  // Role-based access control
  final String? role;

  UserModel({
    required this.uid,
    required this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.imageUrl,
    this.isActive,
    this.totalBusinesses,
    this.totalRevenue,
    this.totalTransactions,
    this.totalIncomes,
    this.totalExpenses,
    this.role,
  });

  /// Converts UserModel object to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'totalBusinesses': totalBusinesses,
      'totalRevenue': totalRevenue,
      'totalTransactions': totalTransactions,
      'totalIncomes': totalIncomes,
      'totalExpenses': totalExpenses,
      'role': role,
    };
  }

  /// Creates UserModel object from Map data
  /// 
  /// Parameters:
  /// - [map]: Map containing user data from Firestore
  /// 
  /// Returns UserModel with default values for missing fields
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? false,
      totalBusinesses: map['totalBusinesses'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      totalTransactions: map['totalTransactions'] ?? 0,
      totalIncomes: (map['totalIncomes'] ?? 0.0).toDouble(),
      totalExpenses: (map['totalExpenses'] ?? 0.0).toDouble(),
      role: map['role'] ?? 'user', // Default role if not provided
    );
  }

  /// Creates UserModel object from Firestore DocumentSnapshot
  /// 
  /// Parameters:
  /// - [doc]: Firestore document snapshot
  /// 
  /// Returns UserModel with document ID as uid
  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? false,
      totalBusinesses: data['totalBusinesses'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      totalTransactions: data['totalTransactions'] ?? 0,
      totalIncomes: (data['totalIncomes'] ?? 0.0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? 0.0).toDouble(),
      role: data['role'] ?? 'user', // Default role if not provided
    );
  }
}
