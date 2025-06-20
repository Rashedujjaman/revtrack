import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/screens/login_screen.dart';
import 'package:revtrack/services/firebase_service.dart';
import 'package:revtrack/services/snackbar_service.dart';
// import 'package:revtrack/services/firebase_service.dart';
import 'package:revtrack/theme/theme_provider.dart';
import 'package:revtrack/services/authentication_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/models/user_model.dart';
import 'package:revtrack/widgets/edit_profile_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //*************************************************************************************************************************** */
  get userId => Provider.of<UserProvider>(context, listen: false).userId;
  late UserModel user;

  bool isLoading = true;
  //*************************************************************************************************************************** */

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen is initialized
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      user = await FirebaseService().getUserData(userId);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Handle error
        SnackbarService().errorMessage(context, e.toString());
      }
    }
  }

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
        SnackbarService().successMessage(context, 'Logged out successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        // Handle error
        SnackbarService().errorMessage(context, e.toString());
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
            // transform: Matrix4.translationValues(0.0, -50.0, 0.0),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: const BorderRadius.all(
                Radius.circular(30),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: .5,
              ),
            ),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(
                                  alpha: 0.5,
                                ),
                          ),
                        ),
                        // const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: user.imageUrl != null &&
                                  user.imageUrl!.isNotEmpty
                              ? CircleAvatar(
                                  // Inner circle for the Icon
                                  radius:
                                      49, // Slightly smaller to create the border
                                  backgroundImage: CachedNetworkImageProvider(
                                      user.imageUrl!),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  // color: Color(0xFF62BDBD),
                                ),
                        ),
                        // const SizedBox(height: 20),
                        Shimmer.fromColors(
                          baseColor: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withValues(alpha: 1),
                          highlightColor: Colors.red,
                          child: Text(
                            user.lastName != null && user.lastName!.isNotEmpty
                                ? user.lastName!
                                : user.firstName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        Text(
                          user.phoneNumber!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          user.email!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            trailing: const Icon(Icons.arrow_forward_ios),
            title: const Text('Edit Profile'),
            onTap: () {
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
                  return EditProfileBottomSheet(user: user);
                },
              );
              updatedData.then((value) {
                if (value != null && value is User) {
                  _fetchUserData();
                }
              });
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
    );
  }
}
