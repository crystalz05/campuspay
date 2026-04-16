import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../domain/entities/data_bundle_entity.dart';
import '../../domain/repositories/data_bundle_repository.dart';
import '../datasources/data_bundle_mock_service.dart';

class DataBundleRepositoryImpl implements DataBundleRepository {
  final DataBundleMockService mockService;
  final SupabaseClient supabaseClient;

  DataBundleRepositoryImpl({
    required this.mockService,
    required this.supabaseClient,
  });

  @override
  Future<Either<Failure, List<DataBundleEntity>>> getBundles(
      NetworkProvider network) async {
    try {
      final bundles = mockService.getBundles(network);
      return Right(bundles);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> purchaseBundle({
    required NetworkProvider network,
    required String phoneNumber,
    required DataBundleEntity bundle,
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
      if (currentBalance < bundle.price) {
        return Left(ServerFailure(
          'Insufficient wallet balance. You need ₦${bundle.price.toStringAsFixed(2)} but have ₦${currentBalance.toStringAsFixed(2)}.',
        ));
      }

      // Step 2: Call mock provider API (may throw on 10% failure)
      final mockResponse = await mockService.processPurchase(
        network: network,
        phoneNumber: phoneNumber,
        bundle: bundle,
      );

      // Step 3: Insert into transactions
      final txRow = await supabaseClient
          .from('transactions')
          .insert({
            'user_id': user.id,
            'type': 'data',
            'amount': bundle.price,
            'status': 'success',
            'reference': mockResponse['reference'] as String?,
            'description':
                '${bundle.name} — ${network.displayName} → $phoneNumber',
          })
          .select()
          .single();

      final transactionId = txRow['id'] as String;

      // Step 4: Insert into data_purchases
      await supabaseClient.from('data_purchases').insert({
        'transaction_id': transactionId,
        'network': network.dbValue,
        'phone_number': phoneNumber,
        'bundle_name': bundle.name,
        'bundle_gb': bundle.sizeGb,
        'mock_response': mockResponse,
      });

      // Step 5: Deduct from wallet
      await supabaseClient
          .from('users')
          .update({'wallet_balance': currentBalance - bundle.price})
          .eq('id', user.id);

      log('Data purchase saved. TX: $transactionId', name: 'DataBundleRepo');

      return Right(TransactionEntity(
        id: txRow['id'] as String,
        userId: txRow['user_id'] as String,
        type: TransactionType.data,
        amount: (txRow['amount'] as num).toDouble(),
        status: TransactionStatus.success,
        reference: txRow['reference'] as String?,
        description: txRow['description'] as String?,
        createdAt: DateTime.parse(txRow['created_at'] as String),
      ));
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e, stack) {
      log('Error purchasing bundle', name: 'DataBundleRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
