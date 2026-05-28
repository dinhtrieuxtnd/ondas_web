import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/ui_text_translations.dart';

class UiTextTranslator {
  static String translate(String key, Locale locale, {Map<String, dynamic>? args}) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return key;

    final map = locale.languageCode == 'vi' ? kUiTextVi : kUiTextEn;
    String translation = map[trimmed] ?? trimmed;

    if (args != null && args.isNotEmpty) {
      args.forEach((placeholder, value) {
        translation = translation.replaceAll('{$placeholder}', value.toString());
      });
    }

    return translation;
  }
}
