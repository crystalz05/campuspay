import 'package:flutter/material.dart';

class PinConfirmationDialog extends StatefulWidget {
  final Function(String pin) onPinEntered;

  const PinConfirmationDialog({super.key, required this.onPinEntered});

  @override
  State<PinConfirmationDialog> createState() => _PinConfirmationDialogState();
}

class _PinConfirmationDialogState extends State<PinConfirmationDialog> {
  String _pin = '';
  final int _pinLength = 4;

  void _onKeyPressed(String value) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
      });
      if (_pin.length == _pinLength) {
        // Automatically submit when full
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onPinEntered(_pin);
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Keeps it feeling like a fixed dialog
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Transaction PIN',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your 4-digit PIN to authorize this transfer.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length ? cs.primary : cs.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildNumberPad(cs, theme),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildNumberPad(ColorScheme cs, ThemeData theme) {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3'], cs, theme),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6'], cs, theme),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9'], cs, theme),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 64),
            _buildNumberButton('0', cs, theme),
            SizedBox(
              width: 64,
              child: IconButton(
                onPressed: _onDeletePressed,
                icon: const Icon(Icons.backspace_outlined),
                color: cs.onSurface,
                iconSize: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers, ColorScheme cs, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberButton(n, cs, theme)).toList(),
    );
  }

  Widget _buildNumberButton(String text, ColorScheme cs, ThemeData theme) {
    return TextButton(
      onPressed: () => _onKeyPressed(text),
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Text(
        text,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
