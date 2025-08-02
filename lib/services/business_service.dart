import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:revtrack/models/business_model.dart';
import 'dart:io';

class BusinessService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Add business
  Future<void> addBusiness(String userId, String name, String? logoUrl) async {
    try {
      await firestore.collection('Business').doc().set({
        'name': name,
        'logoUrl': logoUrl ?? '',
        'userId': userId,
        'dateCreated': DateTime.now(),
        'isDeleted': false,
        'incomes': 0.0,
        'expenses': 0.0,
        'transactionsCount': 0,
      });
    } catch (e) {
      rethrow;
    }
  }

//Update business
  Future<void> updateBusiness(
      String businessId, String name, String logoUrl) async {
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

  //Delete business
  Future<void> deleteBusiness(String businessId) async {
    try {
      await firestore.collection('Business').doc(businessId).update({
        'isDeleted': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  //Get all businesses
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

  //Get business by name
  Future<QueryDocumentSnapshot<Map<String, dynamic>>> getBusinessByName(
      String businessName) async {
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

  // Fetch businesses by user ID
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

  //Upload image to Firebase Storage
  Future<String> uploadImageToFirebase(
      File imageFile, String businessId) async {
    final storageRef = FirebaseStorage.instance.ref().child(
        'business_logos/$businessId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}
