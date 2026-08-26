import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../main.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _green = Color(0xFF1A3C34);
  static const _gold = Color(0xFFC9A84C);

  // Each tab's screen (and its own _load() on initState) is only built the
  // first time it's actually visited — not all four eagerly at cold start —
  // so switching tabs later reuses the same instance and doesn't re-query.
  static const List<Widget Function()> _builders = [
    DashboardScreen.new,
    AccountsScreen.new,
    HistoryScreen.new,
    SettingsScreen.new,
  ];

  final List<Widget?> _screens = List.filled(4, null);

  @override
  void initState() {
    super.initState();
    _screens[_currentIndex] = _builders[_currentIndex]();
    requestedTab.addListener(_onTabRequested);
  }

  @override
  void dispose() {
    requestedTab.removeListener(_onTabRequested);
    super.dispose();
  }

  void _onTabRequested() {
    final index = requestedTab.value;
    if (index != null) {
      _selectTab(index);
      requestedTab.value = null;
    }
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      _screens[index] ??= _builders[index]();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (var i = 0; i < _screens.length; i++)
            _screens[i] ?? const SizedBox.shrink(),
        ],
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
        onTap: () => _selectTab(index),
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