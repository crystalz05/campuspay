import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickActionItem(
              icon: Icons.school_outlined,
              label: 'Pay Fees',
              onTap: () {
                // TODO: Navigate to Pay Fees
              },
            ),
            _QuickActionItem(
              icon: Icons.wifi_protected_setup_outlined,
              label: 'Buy Data',
              onTap: () {
                // TODO: Navigate to Buy Data
              },
            ),
            _QuickActionItem(
              icon: Icons.outbox_outlined,
              label: 'Transfer',
              onTap: () {
                // TODO: Navigate to Transfer
              },
            ),
            _QuickActionItem(
              icon: Icons.receipt_long_outlined,
              label: 'History',
              onTap: () {
                // TODO: Navigate to History
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(12),
              color: cs.surface,
            ),
            child: Icon(icon, color: cs.primary, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
