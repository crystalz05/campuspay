import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../domain/repositories/fund_wallet_repository.dart';

class FundWalletRepositoryImpl implements FundWalletRepository {
  final SupabaseClient supabaseClient;

  FundWalletRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, TransactionEntity>> fundWallet({
    required double amount,
    required String paymentMethod,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return const Left(AuthFailure('User not authenticated'));

    try {
      // Simulate payment processor delay
      await Future.delayed(const Duration(seconds: 2));

      final txId = await supabaseClient.rpc('fund_wallet', params: {
        'p_user_id': user.id,
        'p_amount': amount,
      });

      if (txId == null) throw Exception('No transaction ID returned');

      log('Wallet funded via RPC. TX: $txId', name: 'FundWalletRepo');

      return Right(TransactionEntity(
        id: txId.toString(),
        userId: user.id,
        type: TransactionType.deposit,
        amount: amount,
        status: TransactionStatus.success,
        description: 'Wallet Top-up ($paymentMethod)',
        createdAt: DateTime.now(),
      ));
    } on PostgrestException catch (e, stack) {
      log('PostgrestException funding wallet', name: 'FundWalletRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message));
    } catch (e, stack) {
      log('Error funding wallet', name: 'FundWalletRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
