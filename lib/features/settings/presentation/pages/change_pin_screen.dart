import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
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
        title: const Text('Change PIN'),
      ),
      body: BlocListener<AuthBloc, CampusAuthState>(
        listener: (context, state) {
          if (state is CampusAuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transaction PIN updated successfully!'),
                backgroundColor: CampusPayTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.blueGrey),
                    const SizedBox(height: 24),
                    Text(
                      'Update Transaction PIN',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This PIN will be required for all your future transactions.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    _buildLabel('Enter New PIN'),
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

                    _buildLabel('Confirm New PIN'),
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

                    const SizedBox(height: 64),
                    BlocBuilder<AuthBloc, CampusAuthState>(
                      builder: (context, state) {
                        final isLoading = state is CampusAuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onSubmit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text('Update PIN'),
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
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
      textAlign: TextAlign.center,
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
                onChanged: (value) {
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
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isFocused ? cs.primary : cs.outline.withValues(alpha: 0.2),
                        width: isFocused ? 1.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isFilled ? cs.primary.withValues(alpha: 0.05) : cs.surface,
                    ),
                    child: Center(
                      child: isFilled
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
                            )
                          : isFocused
                              ? Container(width: 1.5, height: 24, color: cs.primary)
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
