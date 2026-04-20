import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    final bool isCredit = transaction.type == TransactionType.deposit ||
        (transaction.type == TransactionType.transfer &&
            transaction.description?.toLowerCase().contains('received') ==
                true);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor, width: 0.5),
                shape: BoxShape.circle,
                color: cs.surface,
              ),
              child: Icon(
                _getTypeIcon(transaction.type),
                color: cs.primary,
                size: 22,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : ''}${currencyFormat.format(transaction.amount)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isCredit ? Colors.green.shade700 : null,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(status: transaction.status),
              ],
            ),
          ],
        ),
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
