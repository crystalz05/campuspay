import 'package:get_it/get_it.dart';
import '../data/datasources/data_bundle_mock_service.dart';
import '../data/repositories/data_bundle_repository_impl.dart';
import '../domain/repositories/data_bundle_repository.dart';
import '../domain/usecases/get_bundles_usecase.dart';
import '../domain/usecases/purchase_bundle_usecase.dart';
import '../presentation/bloc/data_bundle_bloc.dart';

void initDataBundleDependencies(GetIt sl) {
  // Mock service (singleton so plans stay consistent)
  sl.registerLazySingleton(() => DataBundleMockService());

  // Repository
  sl.registerLazySingleton<DataBundleRepository>(
    () => DataBundleRepositoryImpl(
      mockService: sl(),
      supabaseClient: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBundlesUseCase(sl()));
  sl.registerLazySingleton(() => PurchaseBundleUseCase(sl()));

  // Bloc — Factory for fresh instance per ShellRoute scope
  sl.registerFactory(() => DataBundleBloc(
        getBundlesUseCase: sl(),
        purchaseBundleUseCase: sl(),
      ));
}
