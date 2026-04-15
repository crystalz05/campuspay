import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import '../bloc/fund_wallet_bloc.dart';
import '../bloc/fund_wallet_event.dart';
import '../bloc/fund_wallet_state.dart';

class MockPaymentMethodScreen extends StatefulWidget {
  final double amount;

  const MockPaymentMethodScreen({super.key, required this.amount});

  @override
  State<MockPaymentMethodScreen> createState() => _MockPaymentMethodScreenState();
}

class _MockPaymentMethodScreenState extends State<MockPaymentMethodScreen> {
  String _selectedMethod = 'Card Payment';

  void _onPay(BuildContext context) {
    context.read<FundWalletBloc>().add(
      SubmitFundWalletEvent(
        amount: widget.amount, 
        paymentMethod: _selectedMethod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return BlocConsumer<FundWalletBloc, FundWalletState>(
        listener: (context, state) {
          if (state is FundWalletSuccess) {
            context.pushReplacement('/fund-wallet/result');
          } else if (state is FundWalletError) {
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
          final isProcessing = state is FundWalletProcessing;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Payment Method'),
              leading: BackButton(onPressed: isProcessing ? null : () => context.pop()),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: ElevatedButton(
                onPressed: isProcessing ? null : () => _onPay(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text('Pay ${currencyFormat.format(widget.amount)}', style: const TextStyle(fontSize: 16)),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Summary
                      Center(
                        child: Column(
                          children: [
                            Text('Amount to fund', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(widget.amount),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      Text(
                        'Select Payment Method',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      _MethodBox(
                        title: 'Card Payment',
                        subtitle: 'Instant card top-up',
                        icon: Icons.credit_card,
                        isSelected: _selectedMethod == 'Card Payment',
                        onTap: isProcessing ? null : () => setState(() => _selectedMethod = 'Card Payment'),
                      ),
                      const SizedBox(height: 16),
                      _MethodBox(
                        title: 'Bank Transfer',
                        subtitle: 'Account transfer',
                        icon: Icons.account_balance_outlined,
                        isSelected: _selectedMethod == 'Bank Transfer',
                        onTap: isProcessing ? null : () => setState(() => _selectedMethod = 'Bank Transfer'),
                      ),
                    ],
                  ),
                ),
                
                // Bottom action
              ],
            ),
          );
        },
    );
  }
}

class _MethodBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _MethodBox({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cs.primary : theme.dividerColor,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: isSelected ? cs.primary : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? cs.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
