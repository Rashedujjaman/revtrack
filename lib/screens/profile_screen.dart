import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF64E6F0),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF62BDBD), // Avatar background color
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
            Text(
              'This is the Profile screen',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
