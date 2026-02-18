import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'layout/main_layout.dart';
import 'pages/dashboard_page.dart';
import 'pages/live_map_page.dart';
import 'pages/evidence_page.dart';
import 'pages/alert_history_page.dart';
import 'pages/settings_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not initialized: $e');
  }
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
        GoRoute(path: '/map', builder: (context, state) => const LiveMapPage()),
        GoRoute(
          path: '/evidence',
          builder: (context, state) => const EvidencePage(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertHistoryPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aegis Track',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
