import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'business_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int? _index;
  const MainNavigationScreen([this._index, Key? key]) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  //*************************************************************************************************************************** */
  late int _selectedIndex;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BusinessScreen(),
    const ProfileScreen(),
  ];
  //*************************************************************************************************************************** */

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget._index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      //     decoration: const BoxDecoration(
      //         // color: Theme.of(context).colorScheme.background,
      //         // gradient: LinearGradient(
      //         //   colors: [
      //         //     Color(0xFF64E6F0),
      //         //     Colors.white,
      //         //   ],
      //         //   begin: Alignment.topRight,
      //         //   end: Alignment.bottomLeft,
      //         // ),
      //         ),
      //     child: SafeArea(
      //       child: _screens[_selectedIndex],
      //     )),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context).colorScheme.tertiary,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Business'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
