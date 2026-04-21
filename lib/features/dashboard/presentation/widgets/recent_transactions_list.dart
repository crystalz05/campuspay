import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../history/presentation/widgets/transaction_list_item.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import 'main_nav_wrapper.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to History branch (Index 1)
                final shell = (context.findAncestorWidgetOfExactType<MainNavigationWrapper>())?.navigationShell;
                shell?.goBranch(1);
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: TransactionSkeletonList(itemCount: 3),
              );
            } else if (state is DashboardLoaded) {
              if (state.transactions.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.history_outlined,
                  title: 'No transactions yet',
                  subtitle: 'When you transfer funds or make payments, your history will appear here.',
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.transactions.length,
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  height: 1,
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  final tx = state.transactions[index];
                  return TransactionListItem(
                    transaction: tx,
                    onTap: () {
                      context.push('/history/detail', extra: tx);
                    },
                  );
                },
              );
            } else if (state is DashboardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

