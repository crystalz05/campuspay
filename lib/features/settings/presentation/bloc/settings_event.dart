import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  const UpdateThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
