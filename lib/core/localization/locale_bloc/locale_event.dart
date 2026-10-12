import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedLocaleEvent extends LocaleEvent {
  const LoadSavedLocaleEvent();
}

class ToggleLocaleEvent extends LocaleEvent {
  const ToggleLocaleEvent();
}

class SetLocaleEvent extends LocaleEvent {
  final Locale locale;

  const SetLocaleEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}
