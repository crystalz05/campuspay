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
  Future<Either<Failure, List<DataBundleEntity>>> getBundles(NetworkProvider network) async {
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
      final txId = await supabaseClient.rpc('process_data_purchase', params: {
        'p_user_id': user.id,
        'p_network': network.dbValue,
        'p_phone': phoneNumber,
        'p_bundle_name': bundle.name,
        'p_bundle_gb': bundle.sizeGb,
        'p_amount': bundle.price,
      });

      if (txId == null) throw Exception('No transaction ID returned');

      log('Data bundle purchased via RPC. TX: $txId', name: 'DataBundleRepo');

      return Right(TransactionEntity(
        id: txId.toString(),
        userId: user.id,
        type: TransactionType.data,
        amount: bundle.price,
        status: TransactionStatus.success,
        description: '${bundle.name} — ${network.displayName} → $phoneNumber',
        createdAt: DateTime.now(),
      ));
    } on PostgrestException catch (e, stack) {
      log('PostgrestException purchasing bundle', name: 'DataBundleRepo', error: e, stackTrace: stack);
      final msg = e.message.toLowerCase();
      if (msg.contains('insufficient balance')) {
        return Left(ServerFailure('Insufficient wallet balance to complete this purchase.'));
      }
      return Left(ServerFailure(e.message));
    } catch (e, stack) {
      log('Error purchasing bundle', name: 'DataBundleRepo', error: e, stackTrace: stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
