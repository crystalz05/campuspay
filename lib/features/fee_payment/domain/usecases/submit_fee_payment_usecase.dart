import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../entities/fee_payment_entity.dart';
import '../repositories/fee_payment_repository.dart';

class SubmitFeePaymentUseCase implements UseCase<TransactionEntity, FeePaymentEntity> {
  final FeePaymentRepository repository;

  SubmitFeePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(FeePaymentEntity params) {
    return repository.submitPayment(params);
  }
}
