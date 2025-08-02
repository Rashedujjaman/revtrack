import 'package:firebase_auth/firebase_auth.dart';
import 'package:revtrack/services/firebase_service.dart';

/// Authentication service for managing user authentication with Firebase Auth
/// 
/// Handles user registration, login, logout, and authentication state management
/// Provides comprehensive error handling with user-friendly messages
class AuthenticationService {
  
  /// Creates a new user account with email and password
  /// 
  /// Parameters:
  /// - [userEmail]: User's email address
  /// - [userPassword]: User's password
  /// 
  /// Returns the user's UID on successful creation
  /// Throws formatted error messages on failure
  Future<String> createUser(String userEmail, String userPassword) async {
    try {
      UserCredential userCredential = await FirebaseService()
          .auth
          .createUserWithEmailAndPassword(
              email: userEmail, password: userPassword);
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An error occurred while creating the user. Please try again later.';
    }
  }

  /// Signs in an existing user with email and password
  /// 
  /// Parameters:
  /// - [userEmail]: User's email address
  /// - [userPassword]: User's password
  /// 
  /// Returns the user's UID on successful authentication
  /// Returns error message string on failure
  Future<String> signIn(String userEmail, String userPassword) async {
    try {
      UserCredential userCredential = await FirebaseService()
          .auth
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      return 'An error occurred while signing in. Please try again later.';
    }
  }

  /// Signs out the current user
  /// 
  /// Returns true on successful sign out
  /// Throws formatted error messages on failure
  Future<bool> signOut() async {
    try {
      await FirebaseService().auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An error occurred while signing out. Please try again later.';
    }
  }

  /// Checks if a user is currently signed in
  /// 
  /// Returns the current user's UID if signed in, null otherwise
  Future<String?> isUserSignedIn() async {
    User? currentUser = FirebaseService().auth.currentUser;
    return currentUser?.uid;
  }

  /// Handles Firebase Auth errors and returns user-friendly messages
  /// 
  /// Parameters:
  /// - [e]: FirebaseAuthException to handle
  /// 
  /// Returns a user-friendly error message string
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'The provided credential is invalid.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }
}
