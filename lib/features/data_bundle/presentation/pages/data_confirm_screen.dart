import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/data_bundle_entity.dart';
import '../bloc/data_bundle_bloc.dart';
import '../bloc/data_bundle_event.dart';
import '../bloc/data_bundle_state.dart';

class DataConfirmScreen extends StatelessWidget {
  final NetworkProvider network;
  final String phoneNumber;
  final DataBundleEntity bundle;

  const DataConfirmScreen({
    super.key,
    required this.network,
    required this.phoneNumber,
    required this.bundle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat =
        NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return BlocConsumer<DataBundleBloc, DataBundleState>(
      listener: (context, state) {
        if (state is DataBundlePurchaseSuccess) {
          context.pushReplacement('/buy-data/result');
        } else if (state is DataBundleError) {
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
        final isProcessing = state is DataBundlePurchasing;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Purchase'),
            leading: BackButton(
              onPressed: isProcessing ? null : () => context.pop(),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () => context.read<DataBundleBloc>().add(
                PurchaseBundleEvent(
                  network: network,
                  phoneNumber: phoneNumber,
                  bundle: bundle,
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white),
              )
                  : Text('Pay ${currencyFormat.format(bundle.price)}'),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Summary Card
                    Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wifi,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Data Purchase Summary',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        _Row(label: 'Network', value: network.displayName),
                        _Row(label: 'Phone Number', value: phoneNumber),
                        _Row(label: 'Bundle', value: bundle.name),
                        _Row(
                          label: 'Data Size',
                          value: bundle.sizeGb < 1
                              ? '${(bundle.sizeGb * 1024).toInt()}MB'
                              : '${bundle.sizeGb % 1 == 0 ? bundle.sizeGb.toInt() : bundle.sizeGb}GB',
                        ),
                        _Row(label: 'Validity', value: bundle.validity),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                currencyFormat.format(bundle.price),
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

                    const SizedBox(height: 20),
                    // Wallet notice
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cs.onSurface.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: cs.onSurface, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This amount will be deducted from your CampusPay wallet upon confirmation.',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom CTA
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
