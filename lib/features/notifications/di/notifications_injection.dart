import 'package:get_it/get_it.dart';
import '../data/datasources/notification_remote_data_source.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/mark_notification_as_read_usecase.dart';
import '../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../presentation/bloc/notifications_bloc.dart';

void initNotificationsDependencies(GetIt sl) {
  // UseCases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  // Blocs
  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),
    ),
  );
}
