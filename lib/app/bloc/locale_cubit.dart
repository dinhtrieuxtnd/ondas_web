import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ondas_web/core/localization/app_locales.dart';
import 'package:ondas_web/core/storage/secure_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  final SecureStorage _storage;

  LocaleCubit({required SecureStorage storage})
      : _storage = storage,
        super(AppLocales.defaultLocale);

  Future<void> load() async {
    final savedCode = await _storage.getLanguageCode();
    emit(AppLocales.fromLanguageCode(savedCode));
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    await _storage.saveLanguageCode(locale.languageCode);
    emit(locale);
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == AppLocales.vi.languageCode
        ? AppLocales.en
        : AppLocales.vi;
    await setLocale(next);
  }
}
