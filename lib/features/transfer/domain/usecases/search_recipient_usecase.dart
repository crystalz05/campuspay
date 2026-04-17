import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/transfer_repository.dart';

class SearchRecipientUseCase implements UseCase<UserEntity, String> {
  final TransferRepository repository;

  SearchRecipientUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(String params) async {
    return await repository.searchRecipient(params);
  }
}
