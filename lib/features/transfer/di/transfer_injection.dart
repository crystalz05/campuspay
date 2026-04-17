import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/transfer_remote_data_source.dart';
import '../data/repositories/transfer_repository_impl.dart';
import '../domain/repositories/transfer_repository.dart';
import '../domain/usecases/process_transfer_usecase.dart';
import '../domain/usecases/search_recipient_usecase.dart';
import '../presentation/bloc/transfer_bloc.dart';

final sl = GetIt.instance;

void initTransfer() {
  // Bloc
  sl.registerFactory(
    () => TransferBloc(
      searchRecipientUseCase: sl(),
      processTransferUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchRecipientUseCase(sl()));
  sl.registerLazySingleton(() => ProcessTransferUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSourceImpl(sl()),
  );
}
