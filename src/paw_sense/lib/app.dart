import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/navigation/fade_page_route.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/supabase_realtime_service.dart';
import 'presentation/providers/cat_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/violation_provider.dart';
import 'presentation/navigation/bottom_nav_bar.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/cat_settings/cat_settings_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

class PawSenseApp extends StatelessWidget {
  final SupabaseRealtimeService realtimeService;
  final DashboardProvider dashboardProvider;
  final CatProvider catProvider;
  final ViolationProvider violationProvider;

  const PawSenseApp({
    super.key,
    required this.realtimeService,
    required this.dashboardProvider,
    required this.catProvider,
    required this.violationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'PawSense',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          debugShowCheckedModeBanner: false,
          home: _AuthGate(
            realtimeService: realtimeService,
            dashboardProvider: dashboardProvider,
            catProvider: catProvider,
            violationProvider: violationProvider,
          ),
        );
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  final SupabaseRealtimeService realtimeService;
  final DashboardProvider dashboardProvider;
  final CatProvider catProvider;
  final ViolationProvider violationProvider;

  const _AuthGate({
    required this.realtimeService,
    required this.dashboardProvider,
    required this.catProvider,
    required this.violationProvider,
  });

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _dataLoaded = false;

  Future<void> _loadData() async {
    if (_dataLoaded) return;
    _dataLoaded = true;
    await widget.catProvider.loadCats();
    await widget.dashboardProvider.loadCats();
    widget.dashboardProvider.loadLiveCats();
    widget.dashboardProvider.loadSystemMode();
    widget.violationProvider.loadViolations();
    widget.catProvider.subscribeToRealtime(widget.realtimeService);
    widget.dashboardProvider.subscribeToRealtime(widget.realtimeService);
    widget.violationProvider.subscribeToRealtime(widget.realtimeService);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          _loadData();
          return const _MobileWrapper();
        }

        _dataLoaded = false;
        return const LoginScreen();
      },
    );
  }
}

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

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  void _openSettings() {
    Navigator.push(
      context,
      FadePageRoute(page: const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToHistory: () => _navigateTo(2),
        onOpenSettings: _openSettings,
      ),
      const CatSettingsScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
