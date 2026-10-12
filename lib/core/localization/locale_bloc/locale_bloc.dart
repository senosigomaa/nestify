import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'locale_event.dart';
import 'locale_state.dart';

/// LocaleBloc manages dynamic on-the-fly toggling between English (LTR) and Arabic (RTL),
/// persisting preferences locally in Hive.
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String settingsBoxName = 'nestify_settings';
  static const String localeKey = 'selected_language';

  LocaleBloc() : super(const LocaleState(locale: Locale('en'))) {
    on<LoadSavedLocaleEvent>(_onLoadSavedLocale);
    on<ToggleLocaleEvent>(_onToggleLocale);
    on<SetLocaleEvent>(_onSetLocale);
  }

  Future<void> _onLoadSavedLocale(
    LoadSavedLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      if (Hive.isBoxOpen(settingsBoxName)) {
        final box = Hive.box(settingsBoxName);
        final langCode = box.get(localeKey, defaultValue: 'en') as String;
        emit(LocaleState(locale: Locale(langCode)));
      }
    } catch (_) {
      // Fallback to default English
    }
  }

  Future<void> _onToggleLocale(
    ToggleLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final newLocale = state.isArabic ? const Locale('en') : const Locale('ar');
    emit(state.copyWith(locale: newLocale));

    try {
      if (Hive.isBoxOpen(settingsBoxName)) {
        final box = Hive.box(settingsBoxName);
        await box.put(localeKey, newLocale.languageCode);
      }
    } catch (_) {}
  }

  Future<void> _onSetLocale(
    SetLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(locale: event.locale));

    try {
      if (Hive.isBoxOpen(settingsBoxName)) {
        final box = Hive.box(settingsBoxName);
        await box.put(localeKey, event.locale.languageCode);
      }
    } catch (_) {}
  }
}
