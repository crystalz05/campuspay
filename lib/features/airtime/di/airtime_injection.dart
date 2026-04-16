import 'package:get_it/get_it.dart';
import '../data/repositories/airtime_repository_impl.dart';
import '../domain/repositories/airtime_repository.dart';
import '../domain/usecases/purchase_airtime_usecase.dart';
import '../presentation/bloc/airtime_bloc.dart';

void initAirtimeDependencies(GetIt sl) {
  // Repositories
  sl.registerLazySingleton<AirtimeRepository>(
    () => AirtimeRepositoryImpl(supabaseClient: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => PurchaseAirtimeUseCase(sl()));

  // Bloc — Factory for fresh instance per ShellRoute scope
  sl.registerFactory(() => AirtimeBloc(purchaseAirtimeUseCase: sl()));
}
