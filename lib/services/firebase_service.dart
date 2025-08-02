import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:revtrack/models/user_model.dart';

/// Firebase service for centralized Firebase operations
/// 
/// Provides unified access to Firebase Auth, Firestore, and Storage
/// with user management operations. Centralizes Firebase interactions
/// to maintain consistency across the app.
/// 
/// Features:
/// - User registration and profile management
/// - Firestore user document operations
/// - Profile image upload to Firebase Storage
/// - Unified error handling for Firebase operations
class FirebaseService {
  /// Firebase Auth instance getter
  FirebaseAuth get auth => FirebaseAuth.instance;
  
  /// Firestore instance getter
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Registers a new user entry in Firestore after authentication
  /// 
  /// Parameters:
  /// - [firstName]: User's first name
  /// - [lastName]: User's last name  
  /// - [email]: User's email address
  /// - [phoneNumber]: User's phone number
  /// - [uid]: Firebase Auth UID
  Future<void> registerEntry(
    String firstName, 
    String lastName, 
    String email,
    String phoneNumber, 
    String uid
  ) async {
    try {
      await firestore.collection('ApplicationUsers').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'imageUrl': '',
        'isActive': true,
        // Initialize user stats for dashboard
        'totalBusinesses': 0,
        'totalRevenue': 0.0,
        'totalTransactions': 0,
        'totalIncomes': 0.0,
        'totalExpenses': 0.0,
        'role': 'user', // Default role
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves user data from Firestore by UID
  /// 
  /// Parameters:
  /// - [uid]: Firebase user UID
  /// 
  /// Returns UserModel object with user data
  /// Throws exception if user not found
  Future<UserModel> getUserData(String uid) async {
    DocumentSnapshot snapshot =
        await firestore.collection('ApplicationUsers').doc(uid).get();
    if (snapshot.exists) {
      return UserModel.fromDocumentSnapshot(snapshot);
    } else {
      throw 'User not found';
    }
  }

  /// Updates user profile information in Firestore
  /// 
  /// Parameters:
  /// - [user]: UserModel object with updated information
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await firestore.collection('ApplicationUsers').doc(user.uid).update({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'imageUrl': user.imageUrl,
        'phoneNumber': user.phoneNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  //Upload image to Firebase Storage
  Future<String> uploadImageToFirebase(File imageFile, String userId) async {
    final storageRef = FirebaseStorage.instance.ref().child(
        'user_avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}
