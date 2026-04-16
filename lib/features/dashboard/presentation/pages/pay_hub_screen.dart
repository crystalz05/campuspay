import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayHubScreen extends StatelessWidget {
  const PayHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to do?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Essentials',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.8,
              children: [
                _ServiceTile(
                  icon: Icons.phone_android,
                  label: 'Airtime',
                  color: const Color(0xFFFFCC00),
                  onTap: () => context.push('/airtime'),
                  isLive: true,
                ),
                _ServiceTile(
                  icon: Icons.wifi,
                  label: 'Internet',
                  color: const Color(0xFF0077FF),
                  onTap: () => context.push('/buy-data'),
                  isLive: true,
                ),
                _ServiceTile(
                  icon: Icons.tv,
                  label: 'Cable TV',
                  color: const Color(0xFF8B4513),
                  onTap: () => _showComingSoon(context, 'Cable TV'),
                ),
                _ServiceTile(
                  icon: Icons.bolt,
                  label: 'Electricity',
                  color: const Color(0xFFFFB800),
                  onTap: () => _showComingSoon(context, 'Electricity'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Life Style',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.8,
              children: [
                _ServiceTile(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Solar',
                  color: const Color(0xFFFF6B00),
                  onTap: () => _showComingSoon(context, 'Solar'),
                ),
                _ServiceTile(
                  icon: Icons.directions_bus_outlined,
                  label: 'Transport',
                  color: const Color(0xFF00B248),
                  onTap: () => _showComingSoon(context, 'Transport'),
                ),
                _ServiceTile(
                  icon: Icons.school_outlined,
                  label: 'Education',
                  color: const Color(0xFF673AB7),
                  onTap: () => context.push('/pay-fees'),
                ),
                _ServiceTile(
                  icon: Icons.casino_outlined,
                  label: 'Betting',
                  color: const Color(0xFFE91E63),
                  onTap: () => _showComingSoon(context, 'Betting'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ComingSoonSheet(service: service),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLive;

  const _ServiceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLive
                  ? color.withValues(alpha: 0.3)
                  : theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          )
          // child: Stack(
          //   children: [
          //     if (!isLive)
          //       Positioned(
          //         top: 10,
          //         right: 10,
          //         child: Container(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //           decoration: BoxDecoration(
          //             color: theme.hintColor.withValues(alpha: 0.1),
          //             borderRadius: BorderRadius.circular(6),
          //           ),
          //           child: Text(
          //             'Soon',
          //             style: theme.textTheme.labelSmall?.copyWith(
          //               color: theme.hintColor,
          //               fontSize: 9,
          //             ),
          //           ),
          //         ),
          //       ),
          //   ],
          // ),
        ),
      ),
    );
  }
}

class _ComingSoonSheet extends StatelessWidget {
  final String service;

  const _ComingSoonSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.construction_outlined,
                size: 56, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              '$service Coming Soon',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This service is currently under development and will be available in a future update.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
