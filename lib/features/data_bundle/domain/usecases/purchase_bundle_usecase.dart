import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../entities/data_bundle_entity.dart';
import '../repositories/data_bundle_repository.dart';

class PurchaseBundleUseCase {
  final DataBundleRepository repository;

  PurchaseBundleUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required NetworkProvider network,
    required String phoneNumber,
    required DataBundleEntity bundle,
  }) {
    return repository.purchaseBundle(
      network: network,
      phoneNumber: phoneNumber,
      bundle: bundle,
    );
  }
}
