import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({TransactionType? type}) {
    return repository.getTransactions(type: type);
  }
}
