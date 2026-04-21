import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _SectionHeader('Appearance'),
              _buildThemeTile(context, state.themeMode),
              const SizedBox(height: 24),

              _SectionHeader('Notifications'),
              _SettingToggleTile(
                icon: Icons.notifications_none_rounded,
                label: 'Push Notifications',
                value: true,
                onChanged: (val) {
                  // TODO: Implement notification toggle
                },
              ),
              _SettingToggleTile(
                icon: Icons.email_outlined,
                label: 'Email Alerts',
                value: false,
                onChanged: (val) {
                  // TODO: Implement email alert toggle
                },
              ),
              const SizedBox(height: 24),

              _SectionHeader('Security'),
              _SettingsActionTile(
                icon: Icons.fingerprint_rounded,
                label: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face ID',
                onTap: () {
                  // TODO: Implement biometrics toggle
                },
              ),
              _SettingsActionTile(
                icon: Icons.security_outlined,
                label: 'Security Questions',
                onTap: () {
                  // TODO: Implement security questions
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeMode currentMode) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.palette_outlined, color: cs.primary),
            title: const Text('Theme Mode'),
            subtitle: Text(_getThemeModeName(currentMode)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {currentMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                context.read<SettingsBloc>().add(UpdateThemeEvent(newSelection.first));
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: cs.primary,
                selectedForegroundColor: cs.onPrimary,
                // This changes the border color and width
                side: BorderSide(
                  color: cs.outline.withValues(alpha: 0.1), // Use your desired color here
                  width: 1.0,        // Optional: adjust the thickness
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'System Default';
      case ThemeMode.light: return 'Light Mode';
      case ThemeMode.dark: return 'Dark Mode';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
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

class _SettingToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: cs.primary, size: 22),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: cs.primary,
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: cs.primary, size: 22),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Icon(Icons.chevron_right_rounded, color: cs.outline),
      ),
    );
  }
}
