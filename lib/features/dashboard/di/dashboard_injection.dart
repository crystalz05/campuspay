import 'package:get_it/get_it.dart';
import '../data/datasources/transaction_remote_data_source.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/get_recent_transactions_usecase.dart';
import '../presentation/bloc/dashboard_bloc.dart';

void initDashboardDependencies(GetIt sl) {
  // UseCases
  sl.registerLazySingleton(() => GetRecentTransactionsUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(sl()),
  );

  // Blocs
  sl.registerFactory(() => DashboardBloc(getRecentTransactionsUseCase: sl()));
}
