import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../dashboard/domain/entities/transaction_entity.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm:ss');

    final bool isCredit = transaction.type == TransactionType.deposit ||
        (transaction.type == TransactionType.transfer &&
            transaction.description?.toLowerCase().contains('received') ==
                true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Receipt'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Logic to share receipt/PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt sharing coming soon!')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Primary Info ────────────────────────────────────────────────
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(transaction.type),
                color: cs.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getTitle(transaction),
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isCredit ? '+' : ''}${currencyFormat.format(transaction.amount)}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isCredit ? Colors.green.shade700 : null,
              ),
            ),
            const SizedBox(height: 24),
            _StatusBadge(status: transaction.status),
            const SizedBox(height: 48),

            // ── Detail Table ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                   _DetailRow(
                    label: 'Transaction Date',
                    value: dateFormat.format(transaction.createdAt),
                  ),
                  _divider(cs),
                  _DetailRow(
                    label: 'Reference Number',
                    value: transaction.reference ?? 'N/A',
                    isCopyable: transaction.reference != null,
                  ),
                  _divider(cs),
                  _DetailRow(
                    label: 'Category',
                    value: transaction.type.value.toUpperCase(),
                  ),
                  _divider(cs),
                  _DetailRow(
                    label: 'Description',
                    value: transaction.description ?? 'Wallet Transaction',
                  ),
                  if (transaction.type == TransactionType.fee) ...[
                    _divider(cs),
                    const _DetailRow(
                      label: 'Provider',
                      value: 'Remita (Sandbox)',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Footer ──────────────────────────────────────────────────────
            Text(
              'CampusPay Secure Transaction',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.outline.withValues(alpha: 0.5),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${transaction.id}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.outline.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, color: cs.outline.withValues(alpha: 0.1)),
    );
  }

  String _getTitle(TransactionEntity tx) {
    switch (tx.type) {
      case TransactionType.fee: return 'Fee Payment';
      case TransactionType.data: return 'Data Purchase';
      case TransactionType.transfer: return 'Funds Transfer';
      case TransactionType.deposit: return 'Wallet Funding';
      case TransactionType.airtime: return 'Airtime Recharge';
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.fee: return Icons.school_rounded;
      case TransactionType.data: return Icons.wifi_protected_setup_rounded;
      case TransactionType.transfer: return Icons.outbox_rounded;
      case TransactionType.deposit: return Icons.account_balance_wallet_rounded;
      case TransactionType.airtime: return Icons.phone_android_rounded;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopyable;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    // TODO: Copy to clipboard logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reference copied to clipboard')),
                    );
                  },
                  child: Text(
                    'COPY',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
        label = 'COMPLETED';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
