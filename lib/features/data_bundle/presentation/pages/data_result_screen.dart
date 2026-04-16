import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../bloc/data_bundle_bloc.dart';
import '../bloc/data_bundle_state.dart';

class DataResultScreen extends StatefulWidget {
  const DataResultScreen({super.key});

  @override
  State<DataResultScreen> createState() => _DataResultScreenState();
}

class _DataResultScreenState extends State<DataResultScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh dashboard balance if purchase succeeded
    final state = context.read<DataBundleBloc>().state;
    if (state is DataBundlePurchaseSuccess &&
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

    // Read directly from BLoC state — immune to GoRouter extra loss
    final state = context.read<DataBundleBloc>().state;
    final isSuccess = state is DataBundlePurchaseSuccess &&
        state.transaction.status == TransactionStatus.success;

    DataBundlePurchaseSuccess? successState;
    if (state is DataBundlePurchaseSuccess) successState = state;

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
                          ? Icons.wifi
                          : Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isSuccess ? 'Data Purchase Successful!' : 'Purchase Failed',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? '${successState!.bundle.name} has been sent to ${successState.phoneNumber}.'
                    : 'Something went wrong. Your wallet was not charged.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Receipt
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
                      _ResultRow(
                        label: 'Network',
                        value: successState.bundle.network.displayName,
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Phone',
                        value: successState.phoneNumber,
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Bundle',
                        value: successState.bundle.name,
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Amount Paid',
                        value: currencyFormat
                            .format(successState.transaction.amount),
                        isHighlight: true,
                        highlightColor: Colors.green.shade700,
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _ResultRow(
                        label: 'Date',
                        value: dateFormat.format(
                            successState.transaction.createdAt.toLocal()),
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
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Try Again',
                            style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600)),
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
