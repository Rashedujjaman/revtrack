import 'package:revtrack/services/business_stats_service.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:flutter/foundation.dart';

class BusinessStatsMigrationService {
  final BusinessStatsService _statsService = BusinessStatsService();
  final BusinessService _businessService = BusinessService();

  /// Initialize stats for all businesses (run this once for migration)
  Future<void> initializeAllBusinessStats(String userId) async {
    try {
      debugPrint('Starting business stats migration for user: $userId');
      
      // Fetch all businesses for the user
      final businesses = await _businessService.getBusinessesByUser(userId);

      // Uncomment the line below if you want to migrate all businesses regardless of user
      // final businesses = await _businessService.getAllBusinesses();
      
      for (final business in businesses) {
        debugPrint('Initializing stats for business: ${business.name} (${business.id})');
        await _statsService.initializeBusinessStats(business.id);
      }
      
      debugPrint('Business stats migration completed successfully');
    } catch (e) {
      debugPrint('Error during business stats migration: $e');
      rethrow;
    }
  }

  /// Initialize stats for all businesses in the system (admin function)
  Future<void> migrateAllBusinesses() async {
    try {
      debugPrint('Starting business stats migration for all businesses');
      
      // Fetch all businesses regardless of user
      final businesses = await _businessService.getAllBusinesses();
      
      int totalBusinesses = businesses.length;
      int processedBusinesses = 0;
      
      for (final business in businesses) {
        try {
          debugPrint('Initializing stats for business: ${business.name} (${business.id})');
          await _statsService.initializeBusinessStats(business.id);
          
          processedBusinesses++;
          debugPrint('Processed business $processedBusinesses/$totalBusinesses: ${business.name}');
          
          // Add a small delay to avoid overwhelming Firestore
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          debugPrint('Error processing business ${business.id}: $e');
          continue;
        }
      }
      
      debugPrint('Business stats migration completed. Processed $processedBusinesses/$totalBusinesses businesses.');
    } catch (e) {
      debugPrint('Error during business stats migration: $e');
      rethrow;
    }
  }

  /// Initialize stats for a single business
  Future<void> initializeBusinessStats(String businessId) async {
    try {
      await _statsService.initializeBusinessStats(businessId);
      debugPrint('Stats initialized for business: $businessId');
    } catch (e) {
      debugPrint('Error initializing stats for business $businessId: $e');
      rethrow;
    }
  }
}
