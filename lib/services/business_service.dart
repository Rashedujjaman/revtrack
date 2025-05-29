import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      });
    } catch (e) {
      rethrow;
    }
  }

  //Update business
  // Future<void> updateBusiness(
  //     String uid, String businessName, String businessLogo) async {
  //   try {
  //     await firestore.collection('Business').doc(uid).update({
  //       'businessName': businessName,
  //       'businessLogo': businessLogo,
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
  Future<void> deleteBusiness(String uid) async {
    try {
      await firestore.collection('Business').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  //Get all businesses
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllBusinesses() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Business').get();
      return snapshot.docs;
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

  // //Get business by UID
  // Future<DocumentSnapshot<Map<String, dynamic>>> getBusinessesByUser(
  //     String uid) async {
  //   return await firestore.collection('Business').doc(uid).get();
  // }

  // Fetch businesses by user ID
  Stream<List<Map<String, dynamic>>> getBusinessesByUser(String userId) {
    return firestore
        .collection('Business')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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
