import 'package:flutter/material.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/screens/business_overview_screen.dart';
import 'package:revtrack/widgets/skeleton.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:revtrack/widgets/edit_business_bottom_sheet.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});
  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  //*************************************************************************************************************************** */
  get userId => Provider.of<UserProvider>(context, listen: false).userId;
  List<Business> businesses = [];
  bool isLoading = false;
  //*************************************************************************************************************************** */

  @override
  void initState() {
    super.initState();
    // Optionally, you can fetch businesses when the screen is initialized
    fetchData();
  }

  Future<void> fetchData() async {
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
      setState(() {
        isLoading = false; // Update loading state
      });
    } catch (e) {
      // Handle any errors that occur during the process
      // print('Error getting businesses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'All Your Businesses',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (businesses.isEmpty) {
                        return const Center(
                            child: Text('No businesses found.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 8.0),
                        itemCount: businesses.length,
                        itemBuilder: (context, index) {
                          final business = businesses[index];
                          return Card(
                            color: Theme.of(context)
                                .colorScheme
                                .inversePrimary
                                .withValues(alpha: 0.5),
                            child: ListTile(
                              leading: business.logoUrl != null ||
                                      business.logoUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: business.logoUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                                        return const Icon(
                                            Icons.image_not_supported);
                                      },
                                    )
                                  : const Icon(Icons.business),
                              title: Text(business.name),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BusinessOverviewScreen(business),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
            sheetAnimationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 700),
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
