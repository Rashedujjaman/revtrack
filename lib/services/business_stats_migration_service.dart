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
