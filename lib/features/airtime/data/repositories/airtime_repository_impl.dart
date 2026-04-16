import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../../data_bundle/domain/entities/data_bundle_entity.dart';
import '../../domain/repositories/airtime_repository.dart';

class AirtimeRepositoryImpl implements AirtimeRepository {
  final SupabaseClient supabaseClient;

  AirtimeRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, TransactionEntity>> purchaseAirtime({
    required NetworkProvider network,
    required String phoneNumber,
    required double amount,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return const Left(AuthFailure('User not authenticated'));

    try {
      // Step 1: Check wallet balance
      final userRow = await supabaseClient
          .from('users')
          .select('wallet_balance')
          .eq('id', user.id)
          .single();

      final currentBalance = (userRow['wallet_balance'] as num).toDouble();
      if (currentBalance < amount) {
        return Left(ServerFailure(
          'Insufficient balance. You need ₦${amount.toStringAsFixed(2)} but have ₦${currentBalance.toStringAsFixed(2)}.',
        ));
      }

      // Step 2: Simulate API delay (90% success rate)
      await Future.delayed(const Duration(milliseconds: 1500));
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 10 != 0;
      if (!isSuccess) {
        throw Exception('Network error. Airtime vending failed. Please retry.');
      }

      final mockResponse = {
        'status': 'success',
        'provider': network.dbValue,
        'phone': phoneNumber,
        'amount': amount,
        'reference': 'ATM${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Step 3: Insert transaction
      final txRow = await supabaseClient
          .from('transactions')
          .insert({
            'user_id': user.id,
            'type': 'airtime',
            'amount': amount,
            'status': 'success',
            'reference': mockResponse['reference'],
            'description':
                '₦${amount.toStringAsFixed(0)} Airtime — ${network.displayName} → $phoneNumber',
          })
          .select()
          .single();

      final transactionId = txRow['id'] as String;

      // Step 4: Insert into airtime_purchases
      await supabaseClient.from('airtime_purchases').insert({
        'transaction_id': transactionId,
        'network': network.dbValue,
        'phone_number': phoneNumber,
        'amount': amount,
        'mock_response': mockResponse,
      });

      // Step 5: Deduct from wallet
      await supabaseClient
          .from('users')
          .update({'wallet_balance': currentBalance - amount})
          .eq('id', user.id);

      log('Airtime purchased. TX: $transactionId', name: 'AirtimeRepo');

      return Right(TransactionEntity(
        id: txRow['id'] as String,
        userId: txRow['user_id'] as String,
        type: TransactionType.airtime,
        amount: (txRow['amount'] as num).toDouble(),
        status: TransactionStatus.success,
        reference: txRow['reference'] as String?,
        description: txRow['description'] as String?,
        createdAt: DateTime.parse(txRow['created_at'] as String),
      ));
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e, stack) {
      log('Error purchasing airtime', name: 'AirtimeRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
