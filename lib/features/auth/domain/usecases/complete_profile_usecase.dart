import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileUseCase implements UseCase<UserEntity, CompleteProfileParams> {
  final AuthRepository repository;

  CompleteProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(CompleteProfileParams params) async {
    return await repository.completeProfile(
      matricNumber: params.matricNumber,
      institution: params.institution,
    );
  }
}

class CompleteProfileParams {
  final String matricNumber;
  final String institution;

  CompleteProfileParams({
    required this.matricNumber,
    required this.institution,
  });
}
