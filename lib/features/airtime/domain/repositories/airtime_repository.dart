import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../../data_bundle/domain/entities/data_bundle_entity.dart';

abstract class AirtimeRepository {
  Future<Either<Failure, TransactionEntity>> purchaseAirtime({
    required NetworkProvider network,
    required String phoneNumber,
    required double amount,
  });
}
