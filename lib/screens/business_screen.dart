import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/screens/business_overview_screen.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:revtrack/widgets/business_card.dart';
import 'package:revtrack/widgets/edit_business_bottom_sheet.dart';

/// Business Screen - Displays and manages user's businesses
/// Features: View all businesses, add/edit/delete businesses, navigate to business details
class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});
  
  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen>
    with AutomaticKeepAliveClientMixin {
  
  // State variables
  List<Business> businesses = [];
  bool isLoading = false;
  bool _disposed = false;

  // Get current user ID from provider
  String? get userId => Provider.of<UserProvider>(context, listen: false).userId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Fetches businesses for the current user
  Future<void> _fetchBusinesses() async {
    if (_disposed || userId == null) return;

    setState(() {
      isLoading = true;
    });
    
    try {
      final fetchedBusinesses = await BusinessService().getBusinessesByUser(userId!);
      
      if (_disposed) return;
      
      setState(() {
        businesses = fetchedBusinesses;
        isLoading = false;
      });
    } catch (e) {
      if (!_disposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Shows confirmation dialog before deleting a business
  void _showDeleteDialog(BuildContext context, Business business) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Business'),
          content: Text(
            'Are you sure you want to delete "${business.name}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => _deleteBusiness(context, business),
            ),
          ],
        );
      },
    );
  }

  /// Deletes a business and refreshes the list
  Future<void> _deleteBusiness(BuildContext context, Business business) async {
    Navigator.of(context).pop();
    
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      await BusinessService().deleteBusiness(business.id);
      
      if (mounted) {
        _fetchBusinesses(); // Refresh the list
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Business deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete business: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // const Padding(
          //   padding: EdgeInsets.all(0),
          //   child: Center(
          //     child: Text(
          //       'All Your Businesses',
          //       style: TextStyle(
          //         fontSize: 24,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: userId == null
                ? const Text("User is not loged in")
                : FutureBuilder<void>(
                    future: _fetchBusinesses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          isLoading) {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return const BusinessCardSkeleton();
                          },
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ));
                      }

                      if (businesses.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No businesses found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 32),
                              Text('Tap the "+" button to add a new business and get started tracking your revenue.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,

                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          ),
                        );
                      }

                      return ListView.builder(
                        // padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                        itemCount: businesses.length,
                        itemBuilder: (context, index) {
                          final business = businesses[index];
                          return BusinessCard(
                            business: business,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BusinessOverviewScreen(business),
                                ),
                              );
                            },
                            onEdit: () {
                              final updatedData = showModalBottomSheet(
                                barrierColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(
                                      alpha: .3,
                                    ),
                                elevation: 5,
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                sheetAnimationStyle: const AnimationStyle(
                                  duration: Duration(milliseconds: 700),
                                  curve: Curves.easeInOutBack,
                                ),
                                builder: (context) {
                                  return BusinessBottomSheet(
                                    userId: userId!,
                                    business: business,
                                  );
                                },
                              );
                              updatedData.then((value) {
                                if (value != null) {
                                  _fetchBusinesses();
                                }
                              });
                            },
                            onDelete: () {
                              _showDeleteDialog(context, business);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_business',
        tooltip: 'Add',
        onPressed: () {
          // _showAddBusinessDialog(context, userId);
          final updatedData = showModalBottomSheet(
            barrierColor: Theme.of(context).colorScheme.primary.withValues(
                  alpha: .3,
                ),
            elevation: 5,
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            sheetAnimationStyle: const AnimationStyle(
              duration: Duration(milliseconds: 700),
              curve: Curves.easeInOutBack,
            ),
            builder: (context) {
              return BusinessBottomSheet(
                userId: userId!,
              );
            },
          );
          updatedData.then((value) {
            if (value != null && value is Business) {
              _fetchBusinesses();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
