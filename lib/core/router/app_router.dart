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
import '../../features/dashboard/presentation/pages/profile_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/dashboard/presentation/widgets/main_nav_wrapper.dart';
import '../../features/fee_payment/domain/entities/fee_payment_entity.dart';
import '../../features/fee_payment/presentation/pages/fee_confirm_screen.dart';
import '../../features/fee_payment/presentation/pages/payment_result_screen.dart';
import '../../features/fee_payment/presentation/pages/rrr_entry_screen.dart';
import '../../features/fund_wallet/presentation/pages/fund_amount_screen.dart';
import '../../features/fund_wallet/presentation/pages/fund_result_screen.dart';
import '../../features/fund_wallet/presentation/pages/mock_payment_method_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/dashboard/domain/entities/transaction_entity.dart';
import '../../features/fee_payment/presentation/bloc/fee_payment_bloc.dart';
import '../../features/fund_wallet/presentation/bloc/fund_wallet_bloc.dart';
import '../../features/data_bundle/presentation/bloc/data_bundle_bloc.dart';
import '../../features/data_bundle/presentation/pages/network_select_screen.dart';
import '../../features/data_bundle/presentation/pages/bundle_select_screen.dart';
import '../../features/data_bundle/presentation/pages/data_confirm_screen.dart';
import '../../features/data_bundle/presentation/pages/data_result_screen.dart';
import '../../features/data_bundle/domain/entities/data_bundle_entity.dart';
import '../../features/airtime/presentation/bloc/airtime_bloc.dart';
import '../../features/airtime/presentation/pages/airtime_purchase_screen.dart';
import '../../features/airtime/presentation/pages/airtime_result_screen.dart';
import '../../features/dashboard/presentation/pages/pay_hub_screen.dart';
import '../../features/transfer/presentation/bloc/transfer_bloc.dart';
import '../../features/transfer/presentation/pages/transfer_amount_screen.dart';
import '../../features/transfer/presentation/pages/transfer_result_screen.dart';
import '../../features/transfer/presentation/pages/transfer_search_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/history/presentation/pages/history_screen.dart';
import '../../features/history/presentation/pages/transaction_detail_screen.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/history/presentation/bloc/history_event.dart';
import '../../injection_container.dart';

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
  static GoRouter createRouter(AuthBloc authBloc) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
    final shellHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
    final shellPayKey = GlobalKey<NavigatorState>(debugLabel: 'shellPay');
    final shellProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

    return GoRouter(
      navigatorKey: rootNavigatorKey,
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
        
        // 8. Verification Pending Guard
        if (authState is CampusAuthVerificationRequired) {
          if (!isAuthRoute) return '/login';
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
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(
          path: '/history/detail',
          builder: (context, state) {
            final tx = state.extra as TransactionEntity;
            return TransactionDetailScreen(transaction: tx);
          },
        ),

        // ── Fee Payment Flow ─────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider<FeePaymentBloc>(
              create: (_) => sl<FeePaymentBloc>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/pay-fees',
              builder: (context, state) => const RrrEntryScreen(),
            ),
            GoRoute(
              path: '/pay-fees/confirm',
              builder: (context, state) {
                final details = state.extra as FeePaymentEntity;
                return FeeConfirmScreen(details: details);
              },
            ),
            GoRoute(
              path: '/pay-fees/result',
              builder: (context, state) => const PaymentResultScreen(),
            ),
          ],
        ),

        // ── Fund Wallet Flow ─────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider<FundWalletBloc>(
              create: (_) => sl<FundWalletBloc>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/fund-wallet',
              builder: (context, state) => const FundAmountScreen(),
            ),
            GoRoute(
              path: '/fund-wallet/method',
              builder: (context, state) {
                final amount = state.extra as double;
                return MockPaymentMethodScreen(amount: amount);
              },
            ),
            GoRoute(
              path: '/fund-wallet/result',
              builder: (context, state) => const FundResultScreen(),
            ),
          ],
        ),

        // ── Data Bundle Flow ──────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => BlocProvider<DataBundleBloc>(
            create: (_) => sl<DataBundleBloc>(),
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/buy-data',
              builder: (context, state) => const NetworkSelectScreen(),
            ),
            GoRoute(
              path: '/buy-data/bundles',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return BundleSelectScreen(
                  network: extra['network'] as NetworkProvider,
                  phoneNumber: extra['phone'] as String,
                );
              },
            ),
            GoRoute(
              path: '/buy-data/confirm',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return DataConfirmScreen(
                  network: extra['network'] as NetworkProvider,
                  phoneNumber: extra['phone'] as String,
                  bundle: extra['bundle'] as DataBundleEntity,
                );
              },
            ),
            GoRoute(
              path: '/buy-data/result',
              builder: (context, state) => const DataResultScreen(),
            ),
          ],
        ),

        // ── Airtime Flow ──────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => BlocProvider<AirtimeBloc>(
            create: (_) => sl<AirtimeBloc>(),
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/airtime',
              builder: (context, state) => const AirtimePurchaseScreen(),
            ),
            GoRoute(
              path: '/airtime/result',
              builder: (context, state) => const AirtimeResultScreen(),
            ),
          ],
        ),

        // ── Transfer Flow ─────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => BlocProvider<TransferBloc>(
            create: (_) => sl<TransferBloc>(),
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/transfer',
              builder: (context, state) => const TransferSearchScreen(),
            ),
            GoRoute(
              path: '/transfer-amount',
              builder: (context, state) => const TransferAmountScreen(),
            ),
            GoRoute(
              path: '/transfer-result',
              builder: (context, state) => const TransferResultScreen(),
            ),
          ],
        ),

        // ── Authenticated Shell (Bottom Nav) ─────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => 
              MainNavigationWrapper(navigationShell: navigationShell),
          branches: [
            // Index 0 — Home
            StatefulShellBranch(
              navigatorKey: shellHomeKey,
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            // Index 1 — History
            StatefulShellBranch(
              navigatorKey: shellHistoryKey,
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) => BlocProvider(
                    create: (context) => sl<HistoryBloc>(),
                    child: const HistoryScreen(),
                  ),
                ),
              ],
            ),
            // Index 2 — Pay
            StatefulShellBranch(
              navigatorKey: shellPayKey,
              routes: [
                GoRoute(
                  path: '/pay',
                  builder: (context, state) => const PayHubScreen(),
                ),
              ],
            ),
            // Index 3 — Profile
            StatefulShellBranch(
              navigatorKey: shellProfileKey,
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
