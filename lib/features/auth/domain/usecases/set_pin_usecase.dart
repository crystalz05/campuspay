import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class SetTransactionPinUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  SetTransactionPinUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String pin) async {
    return await repository.setTransactionPin(pin: pin);
  }
}
