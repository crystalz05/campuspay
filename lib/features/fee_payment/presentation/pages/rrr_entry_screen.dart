import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart';
import '../bloc/fee_payment_bloc.dart';
import '../bloc/fee_payment_event.dart';
import '../bloc/fee_payment_state.dart';

class RrrEntryScreen extends StatefulWidget {
  const RrrEntryScreen({super.key});

  @override
  State<RrrEntryScreen> createState() => _RrrEntryScreenState();
}

class _RrrEntryScreenState extends State<RrrEntryScreen> {
  final _rrrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rrrController.dispose();
    super.dispose();
  }

  void _onValidate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<FeePaymentBloc>().add(ValidateRrrEvent(_rrrController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeePaymentBloc, FeePaymentState>(
        listener: (context, state) {
          if (state is FeePaymentValidated) {
            context.push('/pay-fees/confirm', extra: state.details);
          } else if (state is FeePaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is FeePaymentValidating;
          final theme = Theme.of(context);
          final cs = theme.colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Pay Fees'),
              leading: BackButton(onPressed: () => context.pop()),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.school_outlined, color: cs.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Remita Fee', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter your RRR number to validate and pay your fees.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    Text('RRR Number', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _rrrController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 15,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '123456789012345',
                        counterText: '',
                        helperText: 'Your 15-digit Remita Retrieval Reference',
                        helperStyle: theme.textTheme.bodySmall,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Please enter your RRR number';
                        if (value.trim().length != 15) return 'RRR must be exactly 15 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Where to find RRR hint
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cs.onSurface.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: cs.onSurface, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your RRR number can be found on your school fee invoice or the Remita payment portal.',
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _onValidate(context),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Validate RRR'),
                      ),
                    ),

                    // Demo helper
                    const SizedBox(height: 24),
                    _DemoRrrHelper(onTap: (rrr) {
                      _rrrController.text = rrr;
                    }),
                  ],
                ),
              ),
            ),
          );
        },
    );
  }
}

/// Demo widget to prefill test RRR numbers during development/defence
class _DemoRrrHelper extends StatelessWidget {
  final void Function(String rrr) onTap;

  const _DemoRrrHelper({required this.onTap});

  static const _demoRrrs = [
    ('123456789012345', 'ND I Fee — ₦75,000'),
    ('987654321098765', 'HND I Fee — ₦80,000'),
    ('111222333444555', 'Acceptance — ₦25,000'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEST RRR NUMBERS',
          style: theme.textTheme.bodySmall?.copyWith(
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...(_demoRrrs.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onTap(entry.$1),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Row(
                    children: [
                      Icon(Icons.content_paste_go_rounded,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Text(entry.$1,
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600, letterSpacing: 1)),
                      const Spacer(),
                      Text(entry.$2, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ))),
      ],
    );
  }
}
