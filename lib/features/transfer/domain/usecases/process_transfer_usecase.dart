import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/transfer_repository.dart';

class ProcessTransferParams {
  final String receiverId;
  final double amount;
  final String? note;
  final String pin;

  ProcessTransferParams({
    required this.receiverId,
    required this.amount,
    this.note,
    required this.pin,
  });
}

class ProcessTransferUseCase implements UseCase<String, ProcessTransferParams> {
  final TransferRepository repository;

  ProcessTransferUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ProcessTransferParams params) async {
    return await repository.processTransfer(
      receiverId: params.receiverId,
      amount: params.amount,
      note: params.note,
      pin: params.pin,
    );
  }
}
