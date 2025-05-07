import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       Color(0xFF64E6F0),
        //       Colors.white,
        //     ],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: Center(
            child: Column(
          children: <Widget>[
            Container(
              height: 200,
              margin: EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Colors.white.withOpacity(0.8),
              ),
              // child: Center(
              // child: Text(
              //   'Dashboard',
              //   style: TextStyle(
              //     fontSize: 40,
              //     fontWeight: FontWeight.bold,
              //     color: Color.fromARGB(255, 100, 230, 240),
              //   ),
              // ),
              // ),
            ),
          ],
        )),
      ),
    );
  }
}
