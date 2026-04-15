import 'package:get_it/get_it.dart';
import '../data/repositories/fund_wallet_repository_impl.dart';
import '../domain/repositories/fund_wallet_repository.dart';
import '../domain/usecases/fund_wallet_usecase.dart';
import '../presentation/bloc/fund_wallet_bloc.dart';

void initFundWalletDependencies(GetIt sl) {
  // Repositories
  sl.registerLazySingleton<FundWalletRepository>(
    () => FundWalletRepositoryImpl(supabaseClient: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => FundWalletUseCase(sl()));

  // Bloc
  sl.registerFactory(() => FundWalletBloc(fundWalletUseCase: sl()));
}
