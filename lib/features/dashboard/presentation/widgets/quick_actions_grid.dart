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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickActionItem(
              icon: Icons.school_rounded,
              label: 'Pay Fees',
              color: const Color(0xFF6366F1), // Indigo
              onTap: () {
                // TODO: Navigate to Pay Fees
              },
            ),
            _QuickActionItem(
              icon: Icons.wifi_rounded,
              label: 'Buy Data',
              color: const Color(0xFF10B981), // Emerald
              onTap: () {
                // TODO: Navigate to Buy Data
              },
            ),
            _QuickActionItem(
              icon: Icons.send_rounded,
              label: 'Transfer',
              color: const Color(0xFFF59E0B), // Amber
              onTap: () {
                // TODO: Navigate to Transfer
              },
            ),
            _QuickActionItem(
              icon: Icons.receipt_long_rounded,
              label: 'History',
              color: const Color(0xFFEF4444), // Red
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
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
