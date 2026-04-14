import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
  static final GlobalKey<NavigatorState> _shellPayKey = GlobalKey<NavigatorState>(debugLabel: 'shellPay');
  static final GlobalKey<NavigatorState> _shellProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final path = state.uri.path;

        // 1. Allow public paths instantly (bypasses all guards to allow deep-linking recovery)
        if (path == '/forgot-password' || path == '/reset-password') {
          return null;
        }

        // 2. PASSWORD_RECOVERY deep-link guard — always redirect to reset-password
        if (authState is CampusAuthPasswordRecovery) {
          return path == '/reset-password' ? null : '/reset-password';
        }

        // 3. Auth State is Loading
        // We return null here to temporarily allow GoRouter to queue the intended route 
        // without destroying it by forcing a redirect to Splash.
        if (authState is CampusAuthInitial || authState is CampusAuthLoading) {
          return null;
        }

        final isSplash = path == '/';
        final isAuthRoute = path == '/login' || path == '/register';

        // 4. Unauthenticated User Guard
        if (authState is CampusAuthUnauthenticated) {
          // If they are on Splash or any protected view, force them to Login
          if (isSplash || !isAuthRoute) return '/login';
          return null; // Validly accessing login/register
        }

        // 5. Authenticated User Guard
        if (authState is CampusAuthAuthenticated) {
          // Prevent returning to Splash/Auth screens once securely logged in
          if (isSplash || isAuthRoute) return '/dashboard';
          return null; // Validly accessing dashboard/history/pay/profile
        }

        // 6. Incomplete Profile Guard (blocks them from dashboard until filled)
        if (authState is CampusAuthProfileIncomplete) {
          if (path != '/complete-profile') return '/complete-profile';
          return null;
        }

        // 7. Transaction PIN Setup Guard
        if (authState is CampusAuthPinSetupRequired) {
          if (path != '/set-pin') return '/set-pin';
          return null;
        }

        return null;
      },
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
}
