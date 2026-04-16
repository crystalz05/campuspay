import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

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
                // TODO: Navigate to History tab
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is DashboardLoaded) {
              if (state.transactions.isEmpty) {
                return _buildEmptyState(context);
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
                  return _TransactionItem(transaction: tx);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    final bool isCredit = transaction.type == TransactionType.deposit ||
        (transaction.type == TransactionType.transfer &&
            transaction.description?.toLowerCase().contains('received') ==
                true);


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor, width: 0.5),
              shape: BoxShape.circle,
              color: cs.surface,
            ),
            child: Icon(
              _getTypeIcon(transaction.type),
              color: _getTypeColor(transaction.type, cs),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(transaction),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(transaction.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : ''}${currencyFormat.format(transaction.amount)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCredit ? Colors.green.shade700 : null,
                ),
              ),
              const SizedBox(height: 6),
              _StatusBadge(status: transaction.status),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle(TransactionEntity tx) {
    switch (tx.type) {
      case TransactionType.fee:
        return 'School Fee Checkout';
      case TransactionType.data:
        return 'Data Top-Up';
      case TransactionType.transfer:
        return tx.description ?? 'Wallet Transfer';
      case TransactionType.deposit:
        return tx.description ?? 'Wallet Deposit';
      case TransactionType.airtime:
        return tx.description ?? 'Airtime Top-Up';
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.fee:
        return Icons.school_outlined;
      case TransactionType.data:
        return Icons.wifi_protected_setup_outlined;
      case TransactionType.transfer:
        return Icons.outbox_outlined;
      case TransactionType.deposit:
        return Icons.account_balance_wallet_outlined;
      case TransactionType.airtime:
        return Icons.phone_android_outlined;
    }
  }

  Color _getTypeColor(TransactionType type, ColorScheme cs) {
    return cs.primary; // Elegant minimal single color for icons
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case TransactionStatus.success:
        color = Colors.green.shade700;
        label = 'SUCCESS';
        break;
      case TransactionStatus.failed:
        color = Theme.of(context).colorScheme.error;
        label = 'FAILED';
        break;
      case TransactionStatus.pending:
        color = Theme.of(context).colorScheme.secondary;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
