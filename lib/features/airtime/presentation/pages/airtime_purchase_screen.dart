import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data_bundle/domain/entities/data_bundle_entity.dart';
import '../bloc/airtime_bloc.dart';
import '../bloc/airtime_event.dart';
import '../bloc/airtime_state.dart';

class AirtimePurchaseScreen extends StatefulWidget {
  const AirtimePurchaseScreen({super.key});

  @override
  State<AirtimePurchaseScreen> createState() => _AirtimePurchaseScreenState();
}

class _AirtimePurchaseScreenState extends State<AirtimePurchaseScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  NetworkProvider? _selectedNetwork;

  static const _presets = [50.0, 100.0, 200.0, 500.0, 1000.0];

  final _currencyFormat =
      NumberFormat.currency(symbol: '₦', decimalDigits: 0);

  static const _networkColors = {
    NetworkProvider.mtn: Color(0xFFFFCC00),
    NetworkProvider.airtel: Color(0xFFE40000),
    NetworkProvider.glo: Color(0xFF009A3E),
    NetworkProvider.mobile9: Color(0xFF006C35),
    NetworkProvider.smile: Color(0xFF0057A8),
    NetworkProvider.swift: Color(0xFFFF6B35),
  };

  static const _networks = [
    NetworkProvider.mtn,
    NetworkProvider.airtel,
    NetworkProvider.glo,
    NetworkProvider.mobile9,
    NetworkProvider.smile,
    NetworkProvider.swift,
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onBuy(BuildContext context) {
    if (!_formKey.currentState!.validate() || _selectedNetwork == null) {
      if (_selectedNetwork == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a network'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AirtimeBloc>().add(PurchaseAirtimeEvent(
          network: _selectedNetwork!,
          phoneNumber: _phoneController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<AirtimeBloc, AirtimeState>(
      listener: (context, state) {
        if (state is AirtimePurchaseSuccess) {
          context.pushReplacement('/airtime/result');
        } else if (state is AirtimeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: cs.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isProcessing = state is AirtimePurchasing;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Buy Airtime'),
            leading: BackButton(
              onPressed: isProcessing ? null : () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Network', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  // Network chips
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _networks.length,
                    itemBuilder: (context, index) {
                      final n = _networks[index];
                      final isSelected = _selectedNetwork == n;
                      final color = _networkColors[n]!;
                      
                      return GestureDetector(
                        onTap: isProcessing ? null : () => setState(() => _selectedNetwork = n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : cs.outline.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                n.displayName,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: isSelected ? color : cs.onSurface,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text('Phone Number', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    enabled: !isProcessing,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      hintText: '08012345678',
                      counterText: '',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (!RegExp(r'^(070|080|081|090|091)\d{8}$')
                          .hasMatch(v.trim())) {
                        return 'Enter a valid 11-digit Nigerian number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Amount', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    enabled: !isProcessing,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      prefixText: '₦ ',
                      hintText: '0',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter an amount';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 50) {
                        return 'Minimum airtime is ₦50';
                      }
                      if (n > 50000) {
                        return 'Maximum airtime is ₦50,000';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Preset amounts
                  Wrap(
                    spacing: 8,
                    children: _presets.map((amt) {
                      return OutlinedButton(
                        onPressed: isProcessing
                            ? null
                            : () => setState(
                                () => _amountController.text =
                                    amt.toInt().toString()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          side: BorderSide(
                              color: cs.primary.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(_currencyFormat.format(amt),
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isProcessing ? null : () => _onBuy(context),
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Buy Airtime'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
