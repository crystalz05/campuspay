import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetRecentTransactionsUseCase implements UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  GetRecentTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getRecentTransactions();
  }
}
