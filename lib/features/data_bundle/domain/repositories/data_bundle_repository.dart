import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../entities/data_bundle_entity.dart';

abstract class DataBundleRepository {
  Future<Either<Failure, List<DataBundleEntity>>> getBundles(NetworkProvider network);

  Future<Either<Failure, TransactionEntity>> purchaseBundle({
    required NetworkProvider network,
    required String phoneNumber,
    required DataBundleEntity bundle,
  });
}
