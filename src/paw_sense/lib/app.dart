import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/bottom_nav_bar.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/cat_settings/cat_settings_screen.dart';
import 'presentation/screens/history/history_screen.dart';

class PawSenseApp extends StatelessWidget {
  const PawSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawSense',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const _MobileWrapper(),
    );
  }
}

/// Web'de mobil görünümü simüle eden wrapper — 400px genişlik, ortalanmış
class _MobileWrapper extends StatelessWidget {
  const _MobileWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF0EF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const MainShell(),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    CatSettingsScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
