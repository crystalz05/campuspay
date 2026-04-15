import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/fee_payment_entity.dart';
import '../bloc/fee_payment_bloc.dart';
import '../bloc/fee_payment_event.dart';
import '../bloc/fee_payment_state.dart';

class FeeConfirmScreen extends StatelessWidget {
  final FeePaymentEntity details;

  const FeeConfirmScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return BlocConsumer<FeePaymentBloc, FeePaymentState>(
        listener: (context, state) {
        if (state is FeePaymentSuccess) {
          context.pushReplacement('/pay-fees/result');
        } else if (state is FeePaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isProcessing = state is FeePaymentProcessing;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Payment'),
            leading: BackButton(
              onPressed: isProcessing ? null : () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Card
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          // Card Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt_long_outlined,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  'Payment Summary',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Receipt rows
                          _ReceiptRow(label: 'Institution', value: details.institutionName),
                          _ReceiptRow(label: 'Fee Purpose', value: details.feePurpose),
                          _ReceiptRow(label: 'RRR Number', value: details.rrrNumber),
                          // Amount highlighted
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Amount Due',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    )),
                                Text(
                                  currencyFormat.format(details.amount),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.onSurface.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: cs.onSurface, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This amount will be deducted from your CampusPay wallet balance upon confirmation.',
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom action bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: cs.surface,
                  ),
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => context
                            .read<FeePaymentBloc>()
                            .add(SubmitFeePaymentEvent(details)),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Pay ${currencyFormat.format(details.amount)}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
