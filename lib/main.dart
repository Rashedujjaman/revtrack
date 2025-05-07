import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revtrack/screens/main_navigation_screen.dart';
import 'package:revtrack/theme/theme.dart';
import 'package:revtrack/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      darkTheme: ThemeData.dark(),

      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //       seedColor: const Color.fromARGB(255, 100, 230, 240)),
      //   useMaterial3: true,
      // ),
      home: const MainNavigationScreen(),
    );
  }
}
