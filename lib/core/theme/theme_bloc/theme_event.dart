import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedThemeEvent extends ThemeEvent {
  const LoadSavedThemeEvent();
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class SetThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const SetThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
