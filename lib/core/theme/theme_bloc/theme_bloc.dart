import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String boxName = 'theme_box';
  static const String keyIsDark = 'is_dark';
  final Box? themeBox;

  ThemeBloc({this.themeBox})
      : super(const ThemeState(themeMode: ThemeMode.light)) {
    on<LoadSavedThemeEvent>(_onLoadSavedTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  Box? _getBox() {
    if (themeBox != null) return themeBox;
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _onLoadSavedTheme(
    LoadSavedThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final box = _getBox();
      if (box != null) {
        final isDark = box.get(keyIsDark, defaultValue: false) as bool;
        emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
        return;
      }
    } catch (_) {}
    emit(const ThemeState(themeMode: ThemeMode.light));
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeState(themeMode: nextMode));
    try {
      final box = _getBox();
      if (box != null) {
        await box.put(keyIsDark, nextMode == ThemeMode.dark);
      }
    } catch (_) {}
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeState(themeMode: event.themeMode));
    try {
      final box = _getBox();
      if (box != null) {
        await box.put(keyIsDark, event.themeMode == ThemeMode.dark);
      }
    } catch (_) {}
  }
}
