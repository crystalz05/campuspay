import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // Core Services
  sl.registerLazySingleton(() => Supabase.instance.client);

  // Blocs / Cubits
  sl.registerFactory(() => AuthBloc(supabaseClient: sl()));
  sl.registerFactory(() => SplashCubit(supabaseClient: sl()));

  // Use cases, Repositories, Data Sources will go here as features expand
}
