import 'package:campuspay/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
  }) : super(NotificationsInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    final result = await getNotificationsUseCase(NoParams());

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      // Optimistically update the UI if we wanted to, but for now just call use case
      final result = await markNotificationAsReadUseCase(event.notificationId);

      result.fold(
        (failure) => emit(NotificationsError(message: failure.message)),
        (_) {
          // Re-fetch or manually update state
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == event.notificationId) {
              return NotificationEntity(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                read: true,
                type: n.type,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
          emit(NotificationsLoaded(notifications: updatedNotifications));
        },
      );
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final result = await markAllNotificationsAsReadUseCase(NoParams());

      result.fold(
        (failure) => emit(NotificationsError(message: failure.message)),
        (_) {
          final updatedNotifications = currentState.notifications.map((n) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              title: n.title,
              body: n.body,
              read: true,
              type: n.type,
              createdAt: n.createdAt,
            );
          }).toList();
          emit(NotificationsLoaded(notifications: updatedNotifications));
        },
      );
    }
  }
}
