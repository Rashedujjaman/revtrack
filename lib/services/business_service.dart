import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<void> updateBusiness(
      String uid, String businessName, String businessLogo) async {
    try {
      await firestore.collection('Business').doc(uid).update({
        'businessName': businessName,
        'businessLogo': businessLogo,
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
}
