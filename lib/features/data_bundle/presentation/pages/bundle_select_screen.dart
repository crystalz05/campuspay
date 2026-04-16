import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/data_bundle_entity.dart';
import '../bloc/data_bundle_bloc.dart';
import '../bloc/data_bundle_event.dart';
import '../bloc/data_bundle_state.dart';

class BundleSelectScreen extends StatelessWidget {
  final NetworkProvider network;
  final String phoneNumber;

  const BundleSelectScreen({
    super.key,
    required this.network,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat =
        NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('${network.displayName} Data Plans'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<DataBundleBloc, DataBundleState>(
        builder: (context, state) {
          if (state is DataBundleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DataBundleError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context
                          .read<DataBundleBloc>()
                          .add(LoadBundlesEvent(network)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bundles = state is DataBundleLoaded ? state.bundles : [];

          if (bundles.isEmpty) {
            return const Center(child: Text('No plans available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bundles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final bundle = bundles[index];
              return _BundleTile(
                bundle: bundle,
                currencyFormat: currencyFormat,
                onTap: () => context.push(
                  '/buy-data/confirm',
                  extra: {
                    'network': network,
                    'phone': phoneNumber,
                    'bundle': bundle,
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BundleTile extends StatelessWidget {
  final DataBundleEntity bundle;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _BundleTile({
    required this.bundle,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            // Data size badge
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    bundle.sizeGb < 1
                        ? '${(bundle.sizeGb * 1024).toInt()}MB'
                        : '${bundle.sizeGb % 1 == 0 ? bundle.sizeGb.toInt() : bundle.sizeGb}GB',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bundle.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(bundle.validity,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(bundle.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: theme.hintColor, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
