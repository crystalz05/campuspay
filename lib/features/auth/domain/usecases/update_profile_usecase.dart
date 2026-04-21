import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      fullName: params.fullName,
      matricNumber: params.matricNumber,
      institution: params.institution,
    );
  }
}

class UpdateProfileParams {
  final String? fullName;
  final String? matricNumber;
  final String? institution;

  UpdateProfileParams({
    this.fullName,
    this.matricNumber,
    this.institution,
  });
}
