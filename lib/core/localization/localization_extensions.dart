import 'package:flutter/material.dart';

import 'package:ondas_web/core/localization/error_code_translator.dart';
import 'package:ondas_web/core/localization/ui_text_translator.dart';

extension LocalizationExtensions on BuildContext {
  String translateErrorCode(String rawMessage) {
    final locale = Localizations.localeOf(this);
    return ErrorCodeTranslator.translate(rawMessage, locale);
  }

  String translate(String key, [Map<String, dynamic>? args]) {
    final locale = Localizations.localeOf(this);
    return UiTextTranslator.translate(key, locale, args: args);
  }
}
