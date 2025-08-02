import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revtrack/services/navigation_provider.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'business_screen.dart';
import 'bank_accounts_screen.dart';

/// Main navigation screen with bottom navigation bar
/// 
/// Features:
/// - Tab-based navigation with PageView for smooth transitions
/// - Navigation state management with NavigationProvider
/// - Persistent state across tab switches (AutomaticKeepAliveClientMixin)
/// - Four main sections: Dashboard, Business, Bank Accounts, Profile
/// - Custom initial tab support via optional index parameter
class MainNavigationScreen extends StatefulWidget {
  final int? _index;
  
  const MainNavigationScreen([this._index, Key? key]) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with AutomaticKeepAliveClientMixin {
  
  late PageController _pageController;

  // Main application screens
  final List<Widget> _screens = [
    const DashboardScreen(),
    const BusinessScreen(),
    const BankAccountsScreen(),
    const ProfileScreen(),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget._index ?? 0;
    _pageController = PageController(initialPage: initialIndex);

    // Set initial navigation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NavigationProvider>(context, listen: false)
          .setCurrentIndex(initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    Provider.of<NavigationProvider>(context, listen: false)
        .setCurrentIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                Provider.of<NavigationProvider>(context, listen: false)
                    .setCurrentIndex(index);
              },
              children: _screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedItemColor: Theme.of(context).colorScheme.primary,
            selectedItemColor: Theme.of(context).colorScheme.tertiary,
            currentIndex: navigationProvider.currentIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.business), label: 'Business'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance), label: 'Accounts'),
              BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
