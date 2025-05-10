import 'package:flutter/material.dart';
import 'package:revtrack/services/business_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class BusinessScreen extends StatelessWidget {
  // const BusinessScreen({super.key});

  // final List<Map<String, String>> businesses = [
  //   {
  //     'name': 'Tech Solutions',
  //     'logo':
  //         'https://media.licdn.com/dms/image/v2/C4E0BAQFNjO3GokqjtA/company-logo_200_200/company-logo_200_200/0/1644920246364/rf_infinite_sdn_bhd_logo?e=2147483647&v=beta&t=YNIGs77QB31CnUUFvvEjY0MexNQBwIPGpqrSBRVn1eE'
  //   },
  //   {
  //     'name': 'Green Grocers',
  //     'logo':
  //         'https://img.freepik.com/premium-vector/beautiful-unique-logo-design-ecommerce-retail-company_1287271-14561.jpg'
  //   },
  // ];

  Future<void> addBusiness(String userId, String name, String logoUrl) async {
    try {
      // Call the addBusiness method from BusinessService
      await BusinessService().addBusiness(userId, name, logoUrl);
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error adding business: $e');
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
                  padding: const EdgeInsets.all(16.0),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final business = businesses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: business['logoUrl'] != null
                            ? Image.network(
                                business['logoUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              )
                            : const Icon(Icons.business),
                        title: Text(business['name']),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        onPressed: () {
          _showAddBusinessDialog(context, userId
              // userId ?? 'defaultUserId',
              );
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
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding business: $e')),
                    );
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
