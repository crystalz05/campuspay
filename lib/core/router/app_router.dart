import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/complete_profile_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/set_pin_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/dashboard/presentation/pages/placeholders.dart';
import '../../features/dashboard/presentation/pages/settings_screen.dart';
import '../../features/dashboard/presentation/widgets/main_nav_wrapper.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
  static final GlobalKey<NavigatorState> _shellPayKey = GlobalKey<NavigatorState>(debugLabel: 'shellPay');
  static final GlobalKey<NavigatorState> _shellProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/complete-profile', builder: (context, state) => const CompleteProfileScreen()),
      GoRoute(path: '/set-pin', builder: (context, state) => const SetPinScreen()),

      // ── Authenticated Shell (Bottom Nav) ─────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationWrapper(navigationShell: navigationShell),
        branches: [
          // Index 0 — Home
          StatefulShellBranch(
            navigatorKey: _shellHomeKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Index 1 — History
          StatefulShellBranch(
            navigatorKey: _shellHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          // Index 2 — Pay
          StatefulShellBranch(
            navigatorKey: _shellPayKey,
            routes: [
              GoRoute(
                path: '/pay',
                builder: (context, state) => const PayPlaceholderScreen(),
              ),
            ],
          ),
          // Index 3 — Profile
          StatefulShellBranch(
            navigatorKey: _shellProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
