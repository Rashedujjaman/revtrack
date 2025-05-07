import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class BusinessScreen extends StatelessWidget {
  // const BusinessScreen({super.key});
  final List<Map<String, String>> businesses = [
    {
      'name': 'Tech Solutions',
      'logo':
          'https://media.licdn.com/dms/image/v2/C4E0BAQFNjO3GokqjtA/company-logo_200_200/company-logo_200_200/0/1644920246364/rf_infinite_sdn_bhd_logo?e=2147483647&v=beta&t=YNIGs77QB31CnUUFvvEjY0MexNQBwIPGpqrSBRVn1eE'
    },
    {
      'name': 'Green Grocers',
      'logo':
          'https://img.freepik.com/premium-vector/beautiful-unique-logo-design-ecommerce-retail-company_1287271-14561.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final business = businesses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      // leading: CachedNetworkImage(
                      //   imageUrl: business['logo']!,
                      //   errorWidget: (context, url, error) => Icon(Icons.error),
                      // ),
                      title: Text(business['name']!),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your navigation or logic to add a new business
              },
              child: Text('Add New Business'),
            ),
          ],
        ),
      ),
    );
  }
}
