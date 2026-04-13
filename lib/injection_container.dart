import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/di/auth_injection.dart';
import 'features/splash/di/splash_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External / Core (always first, features depend on these) ---
  sl.registerLazySingleton(() => Supabase.instance.client);

  // --- Features ---
  initAuthDependencies(sl);
  initSplashDependencies(sl);
}