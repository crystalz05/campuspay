import 'package:get_it/get_it.dart';
import '../presentation/cubit/splash_cubit.dart';

void initSplashDependencies(GetIt sl) {
  sl.registerFactory(() => SplashCubit(getCurrentUserUseCase: sl()));
}