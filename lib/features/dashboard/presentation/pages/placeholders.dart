import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History'), centerTitle: true),
      body: const Center(child: Text('Coming Soon: Transaction History')),
    );
  }
}

class PayPlaceholderScreen extends StatelessWidget {
  const PayPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments'), centerTitle: true),
      body: const Center(child: Text('Coming Soon: School Fee & Data Payments')),
    );
  }
}
