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
      // Simulate Remita processing
      final remitaResponse = await remitaService.processPayment(details);

      final txId = await supabaseClient.rpc('process_fee_payment', params: {
        'p_user_id': user.id,
        'p_rrr_number': details.rrrNumber,
        'p_institution': details.institutionName,
        'p_fee_purpose': details.feePurpose,
        'p_amount': details.amount,
        'p_remita_response': remitaResponse,
      });

      if (txId == null) throw Exception('No transaction ID returned');

      log('Fee payment processed via RPC. TX: $txId', name: 'FeePaymentRepository');

      return Right(TransactionEntity(
        id: txId.toString(),
        userId: user.id,
        type: TransactionType.fee,
        amount: details.amount,
        status: TransactionStatus.success,
        reference: details.rrrNumber,
        description: '${details.feePurpose} — ${details.institutionName}',
        createdAt: DateTime.now(),
      ));
    } on PostgrestException catch (e, stack) {
      log('PostgrestException submitting fee payment', name: 'FeePaymentRepository', error: e, stackTrace: stack);
      final msg = e.message.toLowerCase();
      if (msg.contains('insufficient balance')) {
        return Left(ServerFailure('Insufficient wallet balance to complete this payment.'));
      }
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stack) {
      log('Error submitting fee payment', name: 'FeePaymentRepository', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
