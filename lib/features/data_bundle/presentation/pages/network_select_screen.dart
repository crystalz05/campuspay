import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/data_bundle_entity.dart';
import '../bloc/data_bundle_bloc.dart';
import '../bloc/data_bundle_event.dart';

class NetworkSelectScreen extends StatefulWidget {
  const NetworkSelectScreen({super.key});

  @override
  State<NetworkSelectScreen> createState() => _NetworkSelectScreenState();
}

class _NetworkSelectScreenState extends State<NetworkSelectScreen> {
  final _phoneController = TextEditingController();
  NetworkProvider? _selectedNetwork;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onProceed() {
    if (_formKey.currentState!.validate() && _selectedNetwork != null) {
      FocusScope.of(context).unfocus();
      context.read<DataBundleBloc>().add(LoadBundlesEvent(_selectedNetwork!));
      context.push(
        '/buy-data/bundles',
        extra: {
          'network': _selectedNetwork!,
          'phone': _phoneController.text.trim(),
        },
      );
    } else if (_selectedNetwork == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a network provider'),
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
        title: const Text('Buy Data'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Network', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _NetworkGrid(
                selected: _selectedNetwork,
                onSelect: (n) => setState(() => _selectedNetwork = n),
              ),
              const SizedBox(height: 32),
              Text('Phone Number', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '08012345678',
                  counterText: '',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  final digits = v.trim().replaceAll(' ', '');
                  if (!RegExp(r'^(070|080|081|090|091)\d{8}$').hasMatch(digits)) {
                    return 'Enter a valid 11-digit Nigerian number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onProceed,
                  child: const Text('View Data Plans'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkGrid extends StatelessWidget {
  final NetworkProvider? selected;
  final ValueChanged<NetworkProvider> onSelect;

  const _NetworkGrid({required this.selected, required this.onSelect});

  static const _networks = [
    NetworkProvider.mtn,
    NetworkProvider.airtel,
    NetworkProvider.glo,
    NetworkProvider.mobile9,
    NetworkProvider.smile,
    NetworkProvider.swift,
  ];

  static const _colors = {
    NetworkProvider.mtn: Color(0xFFFFCC00),
    NetworkProvider.airtel: Color(0xFFE40000),
    NetworkProvider.glo: Color(0xFF009A3E),
    NetworkProvider.mobile9: Color(0xFF006C35),
    NetworkProvider.smile: Color(0xFF0057A8),
    NetworkProvider.swift: Color(0xFFFF6B35),
  };

  static const _icons = {
    NetworkProvider.mtn: Icons.signal_cellular_alt,
    NetworkProvider.airtel: Icons.signal_cellular_alt_2_bar,
    NetworkProvider.glo: Icons.signal_cellular_alt_1_bar,
    NetworkProvider.mobile9: Icons.signal_cellular_4_bar,
    NetworkProvider.smile: Icons.wifi,
    NetworkProvider.swift: Icons.router_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: _networks.map((network) {
        final isSelected = selected == network;
        final color = _colors[network]!;
        return GestureDetector(
          onTap: () => onSelect(network),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : theme.primaryColor.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icons[network], color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  network.displayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
