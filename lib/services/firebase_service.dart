import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static registerEntry(String firstName, String lastName, String email,
      String phoneNumber, uid) async {
    try {
      await firestore.collection('ApplicationUsers').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'imageUrl': '',
        'isActive': true,
        'uid': uid,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get User by UID
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await firestore.collection('ApplicationUsers').doc(uid).get();
  }
}
