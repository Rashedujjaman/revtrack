import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_stats_service.dart';

class UserStatsMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run migration to initialize user stats for all existing users
  static Future<void> migrateAllUsers() async {
    try {
      print('Starting user stats migration...');
      
      // Get all users
      final usersSnapshot = await _firestore.collection('ApplicationUsers').get();
      
      int totalUsers = usersSnapshot.docs.length;
      int processedUsers = 0;
      
      for (var userDoc in usersSnapshot.docs) {
        try {
          final userId = userDoc.id;
          await UserStatsService.initializeUserStats(userId);
          
          processedUsers++;
          print('Processed user $processedUsers/$totalUsers: $userId');
          
          // Add a small delay to avoid overwhelming Firestore
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          print('Error processing user ${userDoc.id}: $e');
          continue;
        }
      }
      
      print('User stats migration completed. Processed $processedUsers/$totalUsers users.');
    } catch (e) {
      print('Error during user stats migration: $e');
      rethrow;
    }
  }

  /// Check if a user has stats initialized
  static Future<bool> hasUserStatsInitialized(String userId) async {
    try {
      final userDoc = await _firestore.collection('ApplicationUsers').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData.containsKey('totalBusinesses') &&
               userData.containsKey('totalRevenue') &&
               userData.containsKey('totalTransactions') &&
               userData.containsKey('totalIncomes') &&
               userData.containsKey('totalExpenses');
      }
      
      return false;
    } catch (e) {
      print('Error checking user stats initialization: $e');
      return false;
    }
  }

  /// Initialize stats for a specific user if not already done
  static Future<void> ensureUserStatsInitialized(String userId) async {
    try {
      final hasStats = await hasUserStatsInitialized(userId);
      
      if (!hasStats) {
        print('Initializing stats for user: $userId');
        await UserStatsService.initializeUserStats(userId);
      }
    } catch (e) {
      print('Error ensuring user stats initialization: $e');
      rethrow;
    }
  }
}
