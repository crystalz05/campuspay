import 'package:get_it/get_it.dart';
import '../data/datasources/remita_mock_service.dart';
import '../data/repositories/fee_payment_repository_impl.dart';
import '../domain/repositories/fee_payment_repository.dart';
import '../domain/usecases/submit_fee_payment_usecase.dart';
import '../domain/usecases/validate_rrr_usecase.dart';
import '../presentation/bloc/fee_payment_bloc.dart';

void initFeePaymentDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton(() => RemitaMockService());

  // Repositories
  sl.registerLazySingleton<FeePaymentRepository>(
    () => FeePaymentRepositoryImpl(
      remitaService: sl(),
      supabaseClient: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ValidateRrrUseCase(sl()));
  sl.registerLazySingleton(() => SubmitFeePaymentUseCase(sl()));

  // Bloc — registered as Factory so each screen gets a fresh instance
  sl.registerFactory(
    () => FeePaymentBloc(
      validateRrrUseCase: sl(),
      submitFeePaymentUseCase: sl(),
    ),
  );
}
