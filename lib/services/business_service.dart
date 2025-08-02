import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/user_stats_service.dart';
import 'dart:io';

/// Service class for managing business operations with Firestore
/// Handles CRUD operations for businesses and integrates with user stats
class BusinessService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Adds a new business to Firestore with automatic user stats updates
  /// 
  /// Parameters:
  /// - [userId]: ID of the user who owns this business
  /// - [name]: Business name
  /// - [logoUrl]: Optional business logo URL
  Future<void> addBusiness(String userId, String name, String? logoUrl) async {
    try {
      final businessRef = await firestore.collection('Business').doc();
      await businessRef.set({
        'name': name,
        'logoUrl': logoUrl ?? '',
        'userId': userId,
        'dateCreated': DateTime.now(),
        'isDeleted': false,
        'incomes': 0.0,
        'expenses': 0.0,
        'transactionsCount': 0,
      });
      
      // Update user stats
      final business = Business(
        id: businessRef.id,
        name: name,
        logoUrl: logoUrl,
        userId: userId,
        dateCreated: Timestamp.fromDate(DateTime.now()),
        isDeleted: false,
        incomes: 0.0,
        expenses: 0.0,
        transactionsCount: 0,
      );
      
      await UserStatsService.onBusinessAdded(userId, business);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing business's information
  /// 
  /// Parameters:
  /// - [businessId]: ID of the business to update
  /// - [name]: New business name
  /// - [logoUrl]: New business logo URL
  Future<void> updateBusiness(String businessId, String name, String logoUrl) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('Business').doc(businessId);
      await docRef.update({
        'name': name,
        'logoUrl': logoUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Soft deletes a business (marks as deleted) with automatic user stats updates
  /// 
  /// Parameters:
  /// - [businessId]: ID of the business to delete
  Future<void> deleteBusiness(String businessId) async {
    try {
      // Get business data before deleting for user stats update
      final businessDoc = await firestore.collection('Business').doc(businessId).get();
      
      await firestore.collection('Business').doc(businessId).update({
        'isDeleted': true,
      });
      
      // Update user stats if business existed
      if (businessDoc.exists) {
        final businessData = businessDoc.data() as Map<String, dynamic>;
        final userId = businessData['userId'] as String;
        await UserStatsService.onBusinessDeleted(userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves all active businesses from Firestore
  /// 
  /// Returns a list of Business objects where isDeleted is false
  Future<List<Business>> getAllBusinesses() async {
    try {
      final snapshot = await firestore
          .collection('Business')
          .where('isDeleted', isEqualTo: false)
          .get();
      return snapshot.docs
          .map((doc) => Business.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Finds a business by its name
  /// 
  /// Parameters:
  /// - [businessName]: Name of the business to search for
  /// 
  /// Returns the first matching business document
  Future<QueryDocumentSnapshot<Map<String, dynamic>>> getBusinessByName(String businessName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Business')
          .where('businessName', isEqualTo: businessName)
          .get();
      return snapshot.docs.first;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves all businesses owned by a specific user
  /// 
  /// Parameters:
  /// - [userId]: User ID to filter businesses by
  /// 
  /// Returns a list of Business objects sorted by name
  Future<List<Business>> getBusinessesByUser(String userId) async {
    final snapshot = await firestore
        .collection('Business')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Business.fromDocumentSnapshot(doc))
        .toList();
  }

  /// Uploads an image file to Firebase Storage for business logos
  /// 
  /// Parameters:
  /// - [imageFile]: Image file to upload
  /// - [businessId]: Business ID for organizing storage path
  /// 
  /// Returns the download URL of the uploaded image
  Future<String> uploadImageToFirebase(File imageFile, String businessId) async {
    final storageRef = FirebaseStorage.instance.ref().child(
        'business_logos/$businessId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}
