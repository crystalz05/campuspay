import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FundAmountScreen extends StatefulWidget {
  const FundAmountScreen({super.key});

  @override
  State<FundAmountScreen> createState() => _FundAmountScreenState();
}

class _FundAmountScreenState extends State<FundAmountScreen> {
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
  
  double get _currentAmount => double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setPresetAmount(double amount) {
    setState(() {
      _amountController.text = amount.toInt().toString();
    });
  }

  void _onProceed() {
    final amount = _currentAmount;
    if (amount >= 500) {
      context.push('/fund-wallet/method', extra: amount);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Minimum top-up amount is ₦500'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Wallet'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much would you like to top up?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            
            // Amount Input Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                filled: true,
                fillColor: cs.onSurface.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.onSurface, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 32),

            Text(
              'Quick Amounts',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3.5,
              children: [
                _buildPresetButton(1000),
                _buildPresetButton(2000),
                _buildPresetButton(5000),
                _buildPresetButton(10000),
              ],
            ),

            const Spacer(),
            
            // Proceed Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentAmount >= 500 ? _onProceed : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(double amount) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = _currentAmount == amount;

    return InkWell(
      onTap: () => _setPresetAmount(amount),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4),
            width: isSelected ? 0.5 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            currencyFormat.format(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSelected ? Colors.white : cs.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
