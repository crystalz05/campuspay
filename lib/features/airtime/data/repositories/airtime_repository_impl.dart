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
      final txId = await supabaseClient.rpc('process_airtime_purchase', params: {
        'p_user_id': user.id,
        'p_network': network.dbValue,
        'p_phone': phoneNumber,
        'p_amount': amount,
      });

      if (txId == null) throw Exception('No transaction ID returned');

      log('Airtime purchased via RPC. TX: $txId', name: 'AirtimeRepo');

      return Right(TransactionEntity(
        id: txId.toString(),
        userId: user.id,
        type: TransactionType.airtime,
        amount: amount,
        status: TransactionStatus.success,
        description: '₦${amount.toStringAsFixed(0)} Airtime — ${network.displayName} → $phoneNumber',
        createdAt: DateTime.now(),
      ));
    } on PostgrestException catch (e, stack) {
      log('PostgrestException purchasing airtime', name: 'AirtimeRepo', error: e, stackTrace: stack);
      final msg = e.message.toLowerCase();
      if (msg.contains('insufficient balance')) {
        return Left(ServerFailure('Insufficient wallet balance to complete this purchase.'));
      }
      return Left(ServerFailure(e.message));
    } catch (e, stack) {
      log('Error purchasing airtime', name: 'AirtimeRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
