import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions();
}
