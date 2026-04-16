import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../bloc/airtime_bloc.dart';
import '../bloc/airtime_state.dart';

class AirtimeResultScreen extends StatefulWidget {
  const AirtimeResultScreen({super.key});

  @override
  State<AirtimeResultScreen> createState() => _AirtimeResultScreenState();
}

class _AirtimeResultScreenState extends State<AirtimeResultScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<AirtimeBloc>().state;
    if (state is AirtimePurchaseSuccess &&
        state.transaction.status == TransactionStatus.success) {
      context.read<AuthBloc>().add(RefreshUserEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat =
        NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy — hh:mm a');

    final state = context.read<AirtimeBloc>().state;
    final isSuccess = state is AirtimePurchaseSuccess &&
        state.transaction.status == TransactionStatus.success;

    AirtimePurchaseSuccess? successState;
    if (state is AirtimePurchaseSuccess) successState = state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
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
                          ? Icons.phone_android
                          : Icons.phone_disabled_outlined,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'Airtime Sent!' : 'Purchase Failed',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? 'Airtime of ${currencyFormat.format(successState!.amount)} was sent to ${successState.phoneNumber}.'
                    : 'Something went wrong. Your wallet was not charged.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (isSuccess && successState != null) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _Row(
                          label: 'Network',
                          value: successState.network.displayName),
                      Divider(height: 1, color: theme.dividerColor),
                      _Row(label: 'Phone', value: successState.phoneNumber),
                      Divider(height: 1, color: theme.dividerColor),
                      _Row(
                        label: 'Amount',
                        value: currencyFormat.format(successState.amount),
                        isHighlight: true,
                        highlightColor: Colors.green.shade700,
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _Row(
                        label: 'Date',
                        value: dateFormat.format(
                            successState.transaction.createdAt.toLocal()),
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _Row(
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
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Try Again',
                        style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color? highlightColor;

  const _Row({
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
