import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:revtrack/screens/main_navigation_screen.dart';
import 'package:revtrack/screens/login_screen.dart';
import 'package:revtrack/services/firebase_options.dart';
import 'package:revtrack/services/authentication_service.dart';
import 'package:revtrack/services/user_provider.dart';
import 'package:revtrack/services/navigation_provider.dart';
import 'package:revtrack/theme/theme_provider.dart';
import 'package:revtrack/theme/theme.dart';

/// Entry point of the RevTrack application
/// 
/// Initializes Firebase, configures Firestore settings, and sets up providers
/// for theme management, user authentication, and navigation state
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Configure Firestore settings for optimal performance
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize theme provider
  final themeProvider = ThemeProvider();

  // Launch app with multiple providers for state management
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeProvider),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ],
    child: const MyApp(),
  ));
}

/// Main application widget
/// 
/// Handles authentication state and navigation between login and main screens
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool? _isLoggedIn;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Update system UI overlay style when app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      _updateSystemUIOverlay();
    }
  }

  /// Updates system UI overlay style based on current theme
  void _updateSystemUIOverlay() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  /// Checks current authentication status and sets user state
  Future<void> _checkAuthStatus() async {
    try {
      String? uid = await AuthenticationService().isUserSignedIn();

      if (uid != null && uid.isNotEmpty) {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUserId(uid);
          setState(() {
            _isLoggedIn = true;
            _isCheckingAuth = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isCheckingAuth = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Update system UI overlay when theme changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSystemUIOverlay();
        });

        // Show loading while theme is initializing
        if (!themeProvider.isInitialized) {
          return MaterialApp(
            title: 'RevTrack',
            debugShowCheckedModeBanner: false,
            theme: lightMode,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Main app with theme and navigation
        return MaterialApp(
          title: 'RevTrack',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: _isCheckingAuth
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : _isLoggedIn == true
                  ? const MainNavigationScreen()
                  : const LoginScreen(),
        );
      },
    );
  }
}
