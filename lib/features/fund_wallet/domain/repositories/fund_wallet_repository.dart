import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';

abstract class FundWalletRepository {
  /// Funds the wallet with the given [amount] and mock [paymentMethod].
  /// On success, returns the newly created transaction record.
  Future<Either<Failure, TransactionEntity>> fundWallet({
    required double amount,
    required String paymentMethod,
  });
}
