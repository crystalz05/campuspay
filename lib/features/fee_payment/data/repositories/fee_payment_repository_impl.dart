import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../domain/entities/fee_payment_entity.dart';
import '../../domain/repositories/fee_payment_repository.dart';
import '../datasources/remita_mock_service.dart';

class FeePaymentRepositoryImpl implements FeePaymentRepository {
  final RemitaMockService remitaService;
  final SupabaseClient supabaseClient;

  FeePaymentRepositoryImpl({
    required this.remitaService,
    required this.supabaseClient,
  });

  @override
  Future<Either<Failure, FeePaymentEntity>> validateRrr(String rrrNumber) async {
    try {
      final result = await remitaService.validateRrr(rrrNumber);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stack) {
      log('Unexpected error validating RRR', name: 'FeePaymentRepository', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> submitPayment(FeePaymentEntity details) async {
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
      if (currentBalance < details.amount) {
        return Left(ServerFailure(
          'Insufficient wallet balance. You need ₦${details.amount.toStringAsFixed(2)} but have ₦${currentBalance.toStringAsFixed(2)}.',
        ));
      }

      // Step 2: Call mock Remita payment processing
      final remitaResponse = await remitaService.processPayment(details);

      // Step 3: Insert into transactions (status: success)
      final txRow = await supabaseClient
          .from('transactions')
          .insert({
            'user_id': user.id,
            'type': 'fee',
            'amount': details.amount,
            'status': 'success',
            'reference': details.rrrNumber,
            'description': '${details.feePurpose} — ${details.institutionName}',
          })
          .select()
          .single();

      final transactionId = txRow['id'] as String;

      // Step 4: Insert fee_payments detail row
      await supabaseClient.from('fee_payments').insert({
        'transaction_id': transactionId,
        'rrr_number': details.rrrNumber,
        'institution_name': details.institutionName,
        'fee_purpose': details.feePurpose,
        'remita_response': remitaResponse,
      });

      // Step 5: Deduct from wallet
      await supabaseClient
          .from('users')
          .update({'wallet_balance': currentBalance - details.amount}).eq('id', user.id);

      log('Fee payment saved. Transaction ID: $transactionId', name: 'FeePaymentRepository');

      return Right(TransactionEntity(
        id: txRow['id'] as String,
        userId: txRow['user_id'] as String,
        type: TransactionType.fee,
        amount: (txRow['amount'] as num).toDouble(),
        status: TransactionStatus.success,
        reference: txRow['reference'] as String?,
        description: txRow['description'] as String?,
        createdAt: DateTime.parse(txRow['created_at'] as String),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e, stack) {
      log('Error submitting fee payment', name: 'FeePaymentRepository', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
