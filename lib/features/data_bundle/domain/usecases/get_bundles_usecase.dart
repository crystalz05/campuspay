import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/data_bundle_entity.dart';
import '../repositories/data_bundle_repository.dart';

class GetBundlesUseCase {
  final DataBundleRepository repository;

  GetBundlesUseCase(this.repository);

  Future<Either<Failure, List<DataBundleEntity>>> call(NetworkProvider network) {
    return repository.getBundles(network);
  }
}
