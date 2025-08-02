import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? imageUrl;
  final bool? isActive;
  final int? totalBusinesses;
  final double? totalRevenue;
  final int? totalTransactions;
  final double? totalIncomes;
  final double? totalExpenses;
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

  // Convert a UserModel object into a Map
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

  // Create a UserModel object from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? false,
      totalBusinesses: map['totalBusinesses'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      totalTransactions: map['totalTransactions'] ?? 0,
      totalIncomes: (map['totalIncomes'] ?? 0.0).toDouble(),
      totalExpenses: (map['totalExpenses'] ?? 0.0).toDouble(),
      role: map['role'] ?? 'user', // Default role if not provided
    );
  }

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
