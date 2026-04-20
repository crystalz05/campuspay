import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences sharedPreferences;
  static const String _themeKey = 'theme_mode';

  SettingsBloc({required this.sharedPreferences}) : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateThemeEvent>(_onUpdateTheme);
  }

  void _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) {
    final themeIndex = sharedPreferences.getInt(_themeKey);
    if (themeIndex != null) {
      final themeMode = ThemeMode.values[themeIndex];
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  Future<void> _onUpdateTheme(UpdateThemeEvent event, Emitter<SettingsState> emit) async {
    await sharedPreferences.setInt(_themeKey, event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
