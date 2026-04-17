import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import '../widgets/pin_confirmation_dialog.dart';

class TransferAmountScreen extends StatefulWidget {
  const TransferAmountScreen({super.key});

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final note = _noteController.text.trim();
      
      context.read<TransferBloc>().add(EnterAmountEvent(amount: amount, note: note));

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: context.read<TransferBloc>(),
            child: PinConfirmationDialog(
              onPinEntered: (pin) {
                Navigator.pop(dialogContext);
                context.read<TransferBloc>().add(SubmitTransferEvent(pin));
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state is TransferSuccess) {
          context.pushReplacement('/transfer-result');
        } else if (state is TransferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! RecipientFound && state is! AmountEntered && state is! TransferProcessing && state is! TransferError) {
          // Fallback if accessed directly without recipient
          return const Scaffold(body: Center(child: Text('Invalid State')));
        }

        final recipient = (state is RecipientFound)
            ? state.recipient
            : (state is AmountEntered) 
                ? state.recipient 
                : (state is TransferProcessing) 
                    ? state.recipient 
                    : (state as TransferError).recipient;

        final isProcessing = state is TransferProcessing;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transfer Details'),
            leading: BackButton(
              onPressed: isProcessing ? null : () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipient Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.primary,
                              child: Text(
                                recipient.fullName.isNotEmpty ? recipient.fullName[0].toUpperCase() : '?',
                                style: TextStyle(color: cs.onPrimary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipient.fullName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        color: cs.onPrimaryContainer, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    recipient.institution ?? 'No Institution',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Amount',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixText: '₦ ',
                          hintText: '0.00',
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter an amount';
                          final numValue = double.tryParse(value.replaceAll(',', ''));
                          if (numValue == null || numValue <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'What\'s this for? (Optional)',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. For food or assignment',
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isProcessing ? null : _onContinue,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Continue to Pay'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
