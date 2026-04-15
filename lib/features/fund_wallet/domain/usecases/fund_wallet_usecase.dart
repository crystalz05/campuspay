import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../repositories/fund_wallet_repository.dart';

class FundWalletUseCase implements UseCase<TransactionEntity, FundWalletParams> {
  final FundWalletRepository repository;

  FundWalletUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(FundWalletParams params) {
    return repository.fundWallet(
      amount: params.amount,
      paymentMethod: params.paymentMethod,
    );
  }
}

class FundWalletParams {
  final double amount;
  final String paymentMethod; // 'card' or 'bank_transfer'

  const FundWalletParams({
    required this.amount,
    required this.paymentMethod,
  });
}
