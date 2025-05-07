import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revtrack/screens/main_navigation_screen.dart';
import 'package:revtrack/services/firebase_options.dart';
// import 'package:revtrack/theme/theme.dart';
import 'package:revtrack/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    print('Firebase initialization error: ${e.code} - ${e.message}');
  } catch (e) {
    print('General initialization error: $e');
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // systemNavigationBarColor: const Color.fromARGB(255, 100, 230, 240),
    // systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RevTrack',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      // darkTheme: darkMode,

      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //       seedColor: const Color.fromARGB(255, 100, 230, 240)),
      //   useMaterial3: true,
      // ),
      home: const MainNavigationScreen(),
    );
  }
}
