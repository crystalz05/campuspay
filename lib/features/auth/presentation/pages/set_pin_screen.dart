import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _formKey = GlobalKey<FormState>();

  String _pin = '';
  String _confirmPin = '';
  String? _errorText;

  void _onSubmit() {
    if (_pin.length < 4) {
      setState(() => _errorText = 'Please enter a 4-digit PIN');
      return;
    }
    if (_pin != _confirmPin) {
      setState(() => _errorText = 'PINs do not match');
      return;
    }
    setState(() => _errorText = null);
    context.read<AuthBloc>().add(SetTransactionPinEvent(pin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Security PIN'), centerTitle: true),
      body: BlocListener<AuthBloc, CampusAuthState>(
        listener: (context, state) {
          if (state is CampusAuthPinSetupSuccess || state is CampusAuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction PIN set successfully!'),
                backgroundColor: CampusPayTheme.success,
              ),
            );
            context.go('/dashboard');
          } else if (state is CampusAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: cs.error),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Set Transaction PIN',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This 4-digit PIN will be required for all transfers and payments.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    _buildLabel('Create New PIN'),
                    const SizedBox(height: 16),
                    _OtpPinField(
                      onChanged: (value) {
                        setState(() {
                          _pin = value;
                          _errorText = null;
                        });
                      },
                    ),

                    const SizedBox(height: 40),

                    _buildLabel('Confirm PIN'),
                    const SizedBox(height: 16),
                    _OtpPinField(
                      onChanged: (value) {
                        setState(() {
                          _confirmPin = value;
                          _errorText = null;
                        });
                      },
                    ),

                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        style: TextStyle(color: cs.error, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 48),
                    BlocBuilder<AuthBloc, CampusAuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is CampusAuthLoading ? null : _onSubmit,
                          child: state is CampusAuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Set PIN & Continue'),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
      textAlign: TextAlign.center,
    );
  }
}

/// A standalone OTP-style 4-digit PIN input widget that uses a hidden
/// [TextField] to capture keyboard events and renders 4 visual boxes.
class _OtpPinField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _OtpPinField({required this.onChanged});

  @override
  State<_OtpPinField> createState() => _OtpPinFieldState();
}

class _OtpPinFieldState extends State<_OtpPinField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTap() {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden text field — positioned off-screen so it captures input
          // without painting any background over the custom boxes.
          Positioned(
            left: -9999,
            child: SizedBox(
              width: 0,
              height: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: false,
                decoration: const InputDecoration.collapsed(hintText: ''),
                onChanged: (value) {
                  // Only allow digits
                  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits != value) {
                    _controller.text = digits;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: digits.length),
                    );
                  }
                  setState(() {});
                  widget.onChanged(digits);
                },
              ),
            ),
          ),
          // Visible pin boxes
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final pin = value.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  final isFilled = index < pin.length;
                  final isFocused = _focusNode.hasFocus && index == pin.length.clamp(0, 3);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 60,
                    height: 68,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isFocused
                            ? cs.secondary
                            : isFilled
                                ? cs.secondary.withValues(alpha: 0.6)
                                : cs.outline.withValues(alpha: 0.35),
                        width: isFocused ? 2 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isFilled
                          ? cs.secondary.withValues(alpha: 0.08)
                          : cs.surface,
                    ),
                    child: Center(
                      child: isFilled
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.secondary,
                              ),
                            )
                          : isFocused
                              ? Container(
                                  width: 2,
                                  height: 24,
                                  color: cs.secondary,
                                )
                              : null,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
