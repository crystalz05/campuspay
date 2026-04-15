import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/fee_payment_entity.dart';
import '../repositories/fee_payment_repository.dart';

class ValidateRrrUseCase implements UseCase<FeePaymentEntity, String> {
  final FeePaymentRepository repository;

  ValidateRrrUseCase(this.repository);

  @override
  Future<Either<Failure, FeePaymentEntity>> call(String rrrNumber) {
    return repository.validateRrr(rrrNumber);
  }
}
