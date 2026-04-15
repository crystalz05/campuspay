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
    context.read<AuthBloc>().add(SetTransactionPinEvent(_pin));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security PIN'),
        automaticallyImplyLeading: false, // Prevents back button to incomplete profile
      ),
      body: BlocListener<AuthBloc, CampusAuthState>(
        listener: (context, state) {
          if (state is CampusAuthPinSetupSuccess || state is CampusAuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transaction PIN set successfully!'),
                backgroundColor: CampusPayTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/dashboard');
          } else if (state is CampusAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), 
                backgroundColor: cs.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Secure Your \nTransactions',
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
                          if (_errorText != null) _errorText = null;
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
                          if (_errorText != null) _errorText = null;
                        });
                      },
                    ),

                    if (_errorText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorText!,
                        style: TextStyle(color: cs.error, fontSize: 14, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 48),
                    BlocBuilder<AuthBloc, CampusAuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is CampusAuthLoading ? null : _onSubmit,
                          child: state is CampusAuthLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onPrimary),
                                )
                              : const Text('Set PIN & Continue'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
                        label: const Text('Log Out'),
                      ),
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
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
      textAlign: TextAlign.center,
    );
  }
}

/// A standalone OTP-style 4-digit PIN input widget that uses a hidden
/// [TextField] to capture keyboard events and renders 4 elegant visual boxes.
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
          // Hidden text field
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

                  final borderColor = isFocused
                      ? cs.primary
                      : isFilled
                          ? cs.primary.withValues(alpha: 0.5)
                          : Theme.of(context).dividerColor;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 56,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: isFocused ? 1.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isFilled
                          ? cs.primary.withValues(alpha: 0.04)
                          : cs.surface,
                    ),
                    child: Center(
                      child: isFilled
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary,
                              ),
                            )
                          : isFocused
                              ? Container(
                                  width: 1.5,
                                  height: 24,
                                  color: cs.primary,
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
