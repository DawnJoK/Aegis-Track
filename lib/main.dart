import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'layout/main_layout.dart';
import 'pages/dashboard_page.dart';
import 'pages/live_map_page.dart';
import 'pages/evidence_page.dart';
import 'pages/alert_history_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';

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
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isLoggingIn = state.uri.toString() == '/login';
    final isSigningUp = state.uri.toString() == '/signup';

    if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
      return '/login';
    }

    if (isLoggedIn && (isLoggingIn || isSigningUp)) {
      return '/';
    }

    return null;
  },
  refreshListenable: _GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
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

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
