import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/wallet_balance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // If the AuthBloc hasn't resolved the user yet (e.g. coming from splash
    // which manages its own auth check), trigger a check so the dashboard
    // receives the CampusAuthAuthenticated state it needs to render.
    final authState = context.read<AuthBloc>().state;
    if (authState is! CampusAuthAuthenticated) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardBloc>()..add(FetchDashboardDataEvent()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuthBloc, CampusAuthState>(
            builder: (context, authState) {
              if (authState is CampusAuthAuthenticated) {
                final user = authState.user;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DashboardBloc>().add(FetchDashboardDataEvent());
                    context.read<AuthBloc>().add(CheckAuthStatusEvent());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        DashboardHeader(fullName: user.fullName),
                        const SizedBox(height: 24),
                        WalletBalanceCard(balance: user.walletBalance),
                        const SizedBox(height: 32),
                        const QuickActionsGrid(),
                        const SizedBox(height: 32),
                        const RecentTransactionsList(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                );
              }

              // Show a loading spinner while the auth check is in progress
              if (authState is CampusAuthLoading || authState is CampusAuthInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              // Fallback — should not normally appear
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
