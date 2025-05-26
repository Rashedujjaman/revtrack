import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/screens/login_screen.dart';
import 'package:revtrack/services/snackbar_service.dart';
// import 'package:revtrack/services/firebase_service.dart';
import 'package:revtrack/theme/theme_provider.dart';
import 'package:revtrack/services/authentication_service.dart';
import 'package:revtrack/services/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const Map<String, String> user = {
    'Name': 'MD RASHEDUJJAMAN REZA',
    'Email': 'rashedujjaman.reza@gmail.com',
    'Phone': '01789456123',
  };

  void _logOut(BuildContext context) async {
    try {
      bool result = await AuthenticationService().signOut();
      if (result && context.mounted) {
        // Clear user ID from provider
        Provider.of<UserProvider>(context, listen: false).clearUserId();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        SnackbarService.successMessage(context, 'Logged out successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        // Handle error
        SnackbarService.errorMessage(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: ListView(
        padding: EdgeInsets.zero,

        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            // height: 200,
            margin: const EdgeInsets.only(bottom: 40),
            decoration: const BoxDecoration(
              // color: Color(0xFF62BDBD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Text(
                  //   'Profile',
                  //   style: TextStyle(
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color.fromARGB(255, 255, 255, 255),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Color(0xFF62BDBD), // Avatar background color
                    child: CircleAvatar(
                      // Inner circle for the Icon
                      radius: 49, // Slightly smaller to create the border
                      backgroundImage: CachedNetworkImageProvider(
                          'https://avatars.githubusercontent.com/u/68024439?v=4'),
                      // backgroundColor: Colors.white, // Border color
                      // child: Icon(
                      //   Icons.person,
                      //   color: Color(0xFF62BDBD), // Icon color
                      //   size: 50,
                      // ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user['Name']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    user['Email']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Text(
                  //   user['Phone']!,
                  //   style: const TextStyle(fontSize: 16),
                  // ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            trailing: const Icon(Icons.arrow_forward_ios),
            title: const Text('Edit Profile'),
            onTap: () {
              // Handle tapping the About us menu item
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => AboutUsScreen()),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
                // Handle toggle logic here
              },
            ),
            title: const Text('Dark Mode'),
          ),
          ListTile(
            iconColor: Colors.red,
            textColor: Colors.red,
            leading: const Icon(Icons.exit_to_app),
            // trailing: const Icon(Icons.arrow_forward_ios),
            title: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Handle tapping the Log Out menu item
              _logOut(context);
            },
          ),
        ],
      ),
      // floatingActionButton: const FloatingActionButton(
      //   tooltip: 'Add', // used by assistive technologies
      //   onPressed: null,
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
