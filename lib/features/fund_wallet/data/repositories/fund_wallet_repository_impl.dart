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
    if (user == null) {
      return const Left(AuthFailure('User not authenticated'));
    }

    try {
      // Simulate payment processor delay
      await Future.delayed(const Duration(seconds: 2));

      // 1. Fetch current wallet balance
      final userRow = await supabaseClient
          .from('users')
          .select('wallet_balance')
          .eq('id', user.id)
          .single();
      
      final currentBalance = (userRow['wallet_balance'] as num).toDouble();

      // 2. Insert transaction record
      final txRow = await supabaseClient
          .from('transactions')
          .insert({
            'user_id': user.id,
            'type': 'deposit',
            'amount': amount,
            'status': 'success',
            'description': 'Wallet Top-up ($paymentMethod)',
          })
          .select()
          .single();

      // 3. Update user's wallet
      await supabaseClient
          .from('users')
          .update({'wallet_balance': currentBalance + amount}).eq('id', user.id);

      log('Wallet funded successfully! Added ₦$amount', name: 'FundWalletRepo');

      return Right(TransactionEntity(
        id: txRow['id'] as String,
        userId: txRow['user_id'] as String,
        type: TransactionType.deposit,
        amount: (txRow['amount'] as num).toDouble(),
        status: TransactionStatus.success,
        reference: txRow['reference'] as String?,
        description: txRow['description'] as String?,
        createdAt: DateTime.parse(txRow['created_at'] as String),
      ));
    } catch (e, stack) {
      log('Error funding wallet', name: 'FundWalletRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
