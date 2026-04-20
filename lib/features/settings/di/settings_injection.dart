import 'package:get_it/get_it.dart';
import '../presentation/bloc/settings_bloc.dart';
import '../presentation/bloc/settings_event.dart';

void initSettingsDependencies(GetIt sl) {
  // Blocs
  sl.registerLazySingleton(
    () => SettingsBloc(sharedPreferences: sl())..add(LoadSettingsEvent()),
  );
}
