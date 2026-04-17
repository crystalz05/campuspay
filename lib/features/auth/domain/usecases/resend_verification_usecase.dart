import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  ResendVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.resendVerificationEmail(email: params);
  }
}
