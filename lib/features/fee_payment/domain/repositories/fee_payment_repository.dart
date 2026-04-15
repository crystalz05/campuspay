import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../entities/fee_payment_entity.dart';

abstract class FeePaymentRepository {
  /// Validates the RRR number with the (mock) Remita service.
  /// Returns [FeePaymentEntity] with resolved fee details on success.
  Future<Either<Failure, FeePaymentEntity>> validateRrr(String rrrNumber);

  /// Submits the payment, persists to Supabase, and deducts the wallet.
  /// Returns the created [TransactionEntity] on success.
  Future<Either<Failure, TransactionEntity>> submitPayment(FeePaymentEntity details);
}
