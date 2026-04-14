import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, CampusAuthState>(
      listener: (context, state) {
        if (state is CampusAuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings'), centerTitle: true),
        body: BlocBuilder<AuthBloc, CampusAuthState>(
          builder: (context, state) {
            final user = state is CampusAuthAuthenticated ? state.user : null;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // ── Profile Card ─────────────────────────────────────────
                if (user != null) _ProfileCard(user: user),
                const SizedBox(height: 24),

                // ── Account ───────────────────────────────────────────────
                _SectionHeader('Account'),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal Information',
                  onTap: () {
                    // TODO: Navigate to profile edit
                  },
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Transaction PIN',
                  onTap: () {
                    context.push('/set-pin');
                  },
                ),
                _SettingsTile(
                  icon: Icons.school_outlined,
                  label: 'Academic Details',
                  subtitle: user?.institution ?? 'Not set',
                  onTap: () {
                    context.push('/complete-profile');
                  },
                ),
                const SizedBox(height: 8),

                // ── About ─────────────────────────────────────────────────
                _SectionHeader('About'),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  label: 'App Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.article_outlined,
                  label: 'Terms & Conditions',
                  onTap: () {},
                ),
                const SizedBox(height: 8),

                // ── Danger Zone ───────────────────────────────────────────
                _SectionHeader('Session'),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  isDestructive: true,
                  onTap: () => _showLogoutConfirmation(context),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: Text('Log Out', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: cs.primary.withValues(alpha: 0.1),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.email, style: theme.textTheme.bodyMedium),
                if (user.matricNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.matricNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive ? cs.error : cs.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: cs.surface,
        leading: Icon(icon, color: isDestructive ? cs.error : cs.secondary, size: 22),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
            : null,
        trailing: onTap != null
            ? Icon(Icons.chevron_right_rounded, color: cs.outline, size: 20)
            : null,
      ),
    );
  }
}
