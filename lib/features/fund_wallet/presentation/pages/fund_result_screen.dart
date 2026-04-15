import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../bloc/fund_wallet_bloc.dart';
import '../bloc/fund_wallet_state.dart';

class FundResultScreen extends StatefulWidget {
  const FundResultScreen({super.key});

  @override
  State<FundResultScreen> createState() => _FundResultScreenState();
}

class _FundResultScreenState extends State<FundResultScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch a silent background refresh to update the dashboard wallet balance
    final bloc = context.read<FundWalletBloc>();
    if (bloc.state is FundWalletSuccess) {
      final tx = (bloc.state as FundWalletSuccess).transaction;
      if (tx.status == TransactionStatus.success) {
        context.read<AuthBloc>().add(RefreshUserEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy — hh:mm a');

    // Read transaction directly from BLoC — immune to GoRouter extra being lost
    final state = context.read<FundWalletBloc>().state;
    final transaction = state is FundWalletSuccess ? state.transaction : null;
    final isSuccess = transaction?.status == TransactionStatus.success;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Status icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isSuccess ? Colors.green.shade700 : cs.error)
                      .withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuccess ? Colors.green.shade700 : cs.error,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.file_download_done_rounded
                          : Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isSuccess ? 'Top Up Successful' : 'Top Up Failed',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? 'Your CampusPay wallet has been successfully funded.'
                    : 'Something went wrong. Please try again.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Transaction Receipt Card
              if (isSuccess && transaction != null) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _ResultRow(
                        label: 'Amount Added',
                        value: currencyFormat.format(transaction.amount),
                        isHighlight: true,
                        highlightColor: Colors.green.shade700,
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Description',
                        value: transaction.description ?? 'Wallet Top-up',
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Date & Time',
                        value: dateFormat.format(transaction.createdAt.toLocal()),
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Status',
                        value: 'SUCCESS',
                        isHighlight: true,
                        highlightColor: Colors.green.shade700,
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // CTAs
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('Back to Dashboard'),
                    ),
                  ),
                  if (!isSuccess) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: BorderSide(color: cs.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                              color: cs.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color? highlightColor;

  const _ResultRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isHighlight ? highlightColor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
