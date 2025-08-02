import 'package:flutter/material.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/screens/business_overview_screen.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:revtrack/widgets/business_card.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/widgets/edit_business_bottom_sheet.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});
  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen>
    with AutomaticKeepAliveClientMixin {
  //*************************************************************************************************************************** */
  get userId => Provider.of<UserProvider>(context, listen: false).userId;
  List<Business> businesses = [];
  bool isLoading = false;
  bool _disposed = false;

  @override
  bool get wantKeepAlive => true;
  //*************************************************************************************************************************** */

  @override
  void initState() {
    super.initState();
    // Optionally, you can fetch businesses when the screen is initialized
    fetchData();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchData() async {
    if (_disposed) return;

    setState(() {
      isLoading = true;
    });
    // Fetch businesses for the user
    await getBusinessesByUser(userId);
  }

  Future<void> addBusiness(String userId, String name, String logoUrl) async {
    try {
      // Call the addBusiness method from BusinessService
      await BusinessService().addBusiness(userId, name, logoUrl);
    } catch (e) {
      // Handle any errors that occur during the process
      // print('Error adding business: $e');
    }
  }

  Future<void> getBusinessesByUser(String userId) async {
    try {
      // Call the getBusinessesByUser method from BusinessService
      businesses = await BusinessService().getBusinessesByUser(userId);

      if (_disposed) return;

      setState(() {
        isLoading = false; // Update loading state
      });
    } catch (e) {
      // Handle any errors that occur during the process
      // print('Error getting businesses: $e');
      if (!_disposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void _showDeleteDialog(BuildContext context, Business business) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Business'),
          content: Text(
              'Are you sure you want to delete "${business.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await BusinessService().deleteBusiness(business.id);
                  if (mounted) {
                    fetchData(); // Refresh the list
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
              },
            ),
          ],
        );
      },
    );
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
                    future: getBusinessesByUser(userId),
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
                                    userId: userId,
                                    business: business,
                                  );
                                },
                              );
                              updatedData.then((value) {
                                if (value != null) {
                                  fetchData();
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
                userId: userId,
              );
            },
          );
          updatedData.then((value) {
            if (value != null && value is Business) {
              fetchData();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
