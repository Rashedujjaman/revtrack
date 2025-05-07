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

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // // FirebaseAuth get auth => _auth;
  // // FirebaseFirestore get firestore => _firestore;

  // /// Register a new user
  // Future<User?> registerUser({
  //   required String firstName,
  //   required String lastName,
  //   required String phoneNumber,
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     await _firestore
  //         .collection('ApplicationUsers')
  //         .doc(userCredential.user!.uid)
  //         .set({
  //       'firstName': firstName,
  //       'lastName': lastName,
  //       'phoneNumber': phoneNumber,
  //       'email': email,
  //       'imageUrl': '',
  //       'isActive': true,
  //       'uid': userCredential.user!.uid,
  //     });

  //     return userCredential.user;
  //   } on FirebaseAuthException catch (e) {
  //     print('Firebase Auth Error: $e');
  //     rethrow;
  //   } catch (e) {
  //     print('Error: $e');
  //     rethrow;
  //   }
  // }

  /// Sign in user
  // Future<User?> signInUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return userCredential.user;
  //   } catch (e) {
  //     print('Sign In Error: $e');
  //     rethrow;
  //   }
  // }

  // /// Get User by UID
  // Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
  //   return await _firestore.collection('ApplicationUsers').doc(uid).get();
  // }

  // /// Sign out user
  // Future<void> signOut() async {
  //   try {
  //     await _auth.signOut();
  //   } catch (e) {
  //     print('Sign Out Error: $e');
  //     rethrow;
  //   }
  // }

  // /// Check if user is signed in
  // bool isUserSignedIn() {
  //   return _auth.currentUser != null;
  // }
}
