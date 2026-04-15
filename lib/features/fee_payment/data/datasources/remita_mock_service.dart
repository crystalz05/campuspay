import 'dart:developer';
import '../../../../core/error/exception.dart';
import '../../domain/entities/fee_payment_entity.dart';

/// Mock Remita service that simulates the Remita RRR validation and payment API.
/// Replace this with the real Remita Flutter widget when the sandbox becomes available.
class RemitaMockService {
  // Simulated database of known RRR numbers for demo/testing
  static const Map<String, _MockRrrRecord> _mockRrrDatabase = {
    '123456789012345': _MockRrrRecord(
      amount: 75000.00,
      feePurpose: 'ND I School Fee (2024/2025)',
      institutionName: 'Auchi Polytechnic',
    ),
    '987654321098765': _MockRrrRecord(
      amount: 80000.00,
      feePurpose: 'HND I School Fee (2024/2025)',
      institutionName: 'Auchi Polytechnic',
    ),
    '111222333444555': _MockRrrRecord(
      amount: 25000.00,
      feePurpose: 'Acceptance Fee',
      institutionName: 'Auchi Polytechnic',
    ),
    '555444333222111': _MockRrrRecord(
      amount: 15000.00,
      feePurpose: 'Late Registration Surcharge',
      institutionName: 'Auchi Polytechnic',
    ),
  };

  /// Validates an RRR number.
  /// Simulates a 1.5s network round trip.
  /// Throws [ServerException] if the RRR is not found.
  Future<FeePaymentEntity> validateRrr(String rrrNumber) async {
    log('Validating RRR: $rrrNumber', name: 'RemitaMockService');
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1500));

    final record = _mockRrrDatabase[rrrNumber.trim()];
    if (record == null) {
      log('RRR not found: $rrrNumber', name: 'RemitaMockService');
      throw const ServerException(
        'RRR not found. Please check the reference number and try again.',
      );
    }

    log('RRR validated successfully: $rrrNumber (₦${record.amount})', name: 'RemitaMockService');
    return FeePaymentEntity(
      rrrNumber: rrrNumber.trim(),
      amount: record.amount,
      institutionName: record.institutionName,
      feePurpose: record.feePurpose,
    );
  }

  /// Simulates processing a payment after the user confirms.
  /// Simulates a 2s processing delay.
  /// Returns a mock Remita response JSON.
  Future<Map<String, dynamic>> processPayment(FeePaymentEntity details) async {
    log('Processing payment for RRR: ${details.rrrNumber}', name: 'RemitaMockService');
    await Future.delayed(const Duration(milliseconds: 2000));

    // Always successful in mock — swap this for real Remita widget result
    final response = {
      'statuscode': '025',
      'status': 'Payment Successful',
      'RRR': details.rrrNumber,
      'transactionId': 'MOCK-${DateTime.now().millisecondsSinceEpoch}',
      'amount': details.amount,
      'message': 'Payment of ₦${details.amount} processed successfully',
    };

    log('Payment processed: $response', name: 'RemitaMockService');
    return response;
  }
}

/// Internal record for the mock RRR database.
class _MockRrrRecord {
  final double amount;
  final String feePurpose;
  final String institutionName;

  const _MockRrrRecord({
    required this.amount,
    required this.feePurpose,
    required this.institutionName,
  });
}
