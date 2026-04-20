import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.markAllAsRead();
  }
}
