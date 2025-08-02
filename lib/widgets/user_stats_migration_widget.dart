import 'package:flutter/material.dart';
import '../services/user_stats_migration_service.dart';

/// Administrative widget for running user statistics migration
/// 
/// Features:
/// - One-time migration execution for user-level statistics
/// - Progress tracking with real-time status updates
/// - Error handling with detailed error messages
/// - Success confirmation with completion status
/// - Disabled button state during migration execution
/// - Comprehensive UI with instructions and warnings
/// - Material Design 3 compliant interface
/// - Admin/debug screen integration support
class UserStatsMigrationWidget extends StatefulWidget {
  const UserStatsMigrationWidget({Key? key}) : super(key: key);

  @override
  State<UserStatsMigrationWidget> createState() => _UserStatsMigrationWidgetState();
}

/// Stateful widget implementation with migration state management
class _UserStatsMigrationWidgetState extends State<UserStatsMigrationWidget> {
  bool _isRunning = false;
  String _status = 'Ready to migrate user stats';

  /// Executes the user statistics migration process
  /// 
  /// Updates UI state during migration, handles errors gracefully,
  /// and provides detailed status feedback to the user.
  Future<void> _runMigration() async {
    setState(() {
      _isRunning = true;
      _status = 'Starting user stats migration...';
    });

    try {
      await UserStatsMigrationService.migrateAllUsers();
      setState(() {
        _status = 'Migration completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Migration failed: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Stats Migration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'User Stats Migration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'This will initialize user-level aggregated statistics for all existing users. '
              'This operation calculates totals from business-level stats and stores them '
              'in user documents for optimal dashboard performance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _status.contains('failed') ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRunning ? null : _runMigration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isRunning
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Running Migration...'),
                      ],
                    )
                  : const Text(
                      'Run Migration',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 10),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• This is a one-time migration for existing users\n'
                    '• New users will have stats initialized automatically\n'
                    '• The migration is safe and can be run multiple times\n'
                    '• After migration, dashboard will load much faster',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}
