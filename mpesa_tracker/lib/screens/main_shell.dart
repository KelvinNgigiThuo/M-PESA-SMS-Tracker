import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _green = Color(0xFF1A3C34);
  static const _gold = Color(0xFFC9A84C);

  final List<Widget> _screens = const [
    DashboardScreen(),
    AccountsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home,
                    'Overview'),
                _navItem(1, Icons.wallet_outlined, Icons.wallet,
                    'My Money'),
                _navItem(2, Icons.list_alt_outlined, Icons.list_alt,
                    'Ledger'),
                _navItem(3, Icons.settings_outlined, Icons.settings,
                    'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? _green : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 18,
                color: isActive ? _gold : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isActive ? _green : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}