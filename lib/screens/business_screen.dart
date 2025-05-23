import 'package:flutter/material.dart';
import 'package:revtrack/models/business_model.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/screens/business_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});

  Future<void> addBusiness(String userId, String name, String logoUrl) async {
    try {
      // Call the addBusiness method from BusinessService
      await BusinessService().addBusiness(userId, name, logoUrl);
    } catch (e) {
      // Handle any errors that occur during the process
      // print('Error adding business: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: userId == null
          ? const Text("User is not loged in")
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: BusinessService().getBusinessesByUser(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final businesses = snapshot.data ?? [];

                if (businesses.isEmpty) {
                  return const Center(child: Text('No businesses found.'));
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
                          .withValues(alpha: .5),
                      // margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: business['logoUrl'] != null
                            ? CachedNetworkImage(
                                imageUrl: business['logoUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              )
                            : const Icon(Icons.business),
                        title: Text(business['name']),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Business businessObject = Business.fromJson(business);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BusinessOverviewScreen(businessObject),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        onPressed: () {
          _showAddBusinessDialog(context, userId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBusinessDialog(BuildContext context, String? userId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController logoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: const Text('Add New Business'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
              ),
              TextField(
                controller: logoController,
                decoration: const InputDecoration(labelText: 'Logo URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final String logoUrl = logoController.text.trim();

                if (name.isNotEmpty && userId != null) {
                  try {
                    await BusinessService().addBusiness(userId, name, logoUrl);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding business: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
