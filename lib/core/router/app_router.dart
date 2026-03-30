import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Add more routes here per PRD (e.g. Dashboard, Transfer, Data, Fees)
    ],
    // Optional: Add redirect logic here to check if user is authenticated
    // e.g. using a Listenable built around Supabase auth state.
    // redirect: (BuildContext context, GoRouterState state) {
    //   return null;
    // },
  );
}
