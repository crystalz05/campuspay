import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase implements UseCase<void, String> {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
