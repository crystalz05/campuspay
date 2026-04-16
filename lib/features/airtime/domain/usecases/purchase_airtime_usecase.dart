import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../../data_bundle/domain/entities/data_bundle_entity.dart';
import '../repositories/airtime_repository.dart';

class PurchaseAirtimeUseCase {
  final AirtimeRepository repository;

  PurchaseAirtimeUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required NetworkProvider network,
    required String phoneNumber,
    required double amount,
  }) {
    return repository.purchaseAirtime(
      network: network,
      phoneNumber: phoneNumber,
      amount: amount,
    );
  }
}
