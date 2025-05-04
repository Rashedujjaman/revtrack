// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({Key? key}) : super(key: key);
  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  bool userLoggedIn = true;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // User? _user;

  // @override
  // void initState() {
  //   super.initState();
  //   _user = _auth.currentUser; // Geting the current user
  // }

  // Perform logout operations here (e.g., clearing user data, resetting authentication status)
  // Example: Clear user session, navigate to login screen
  // Replace the logic below with your actual logout logic
  // void logoutUser(BuildContext context) {
  //   _auth.signOut();
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     (route) => false, // Clear all previous routes from the stack
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.white,
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF62BDBD),
                  ),
                  // child: SizedBox.shrink(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              Color(0xFF62BDBD), // Avatar background color
                          child: CircleAvatar(
                            // Inner circle for the Icon
                            radius: 38, // Slightly smaller to create the border
                            backgroundColor: Colors.white, // Border color
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF62BDBD), // Icon color
                              size: 50,
                            ),
                          ),
                        ),
                      ])), // Empty header to match logged-in state
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About us'),
                onTap: () {
                  // Handle tapping the About us menu item
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => AboutUsScreen()),
                  // );
                },
              ),
              const SizedBox(height: 400),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // logoutUser(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: .2,
                      shadowColor: null,
                      // backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF62BDBD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF62BDBD)),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min, // Keep the Row's width compact
                      children: [
                        Icon(Icons.login),
                        SizedBox(width: 8), // Add some spacing
                        Text('Login', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
