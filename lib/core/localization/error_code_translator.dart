import 'package:flutter/material.dart';

import 'package:ondas_web/core/localization/error_code_translations.dart';

class ErrorCodeTranslator {
  static String translate(String rawMessage, Locale locale) {
    final trimmed = rawMessage.trim();
    if (trimmed.isEmpty) return rawMessage;

    final map = locale.languageCode == 'vi' ? kErrorCodeVi : kErrorCodeEn;

    if (trimmed.contains(',')) {
      final parts = trimmed.split(',');
      return parts
          .map((part) => _translateSingle(part.trim(), map))
          .join(', ');
    }

    return _translateSingle(trimmed, map);
  }

  static String _translateSingle(String raw, Map<String, String> map) {
    final colonIndex = raw.indexOf(':');
    if (colonIndex != -1) {
      final field = raw.substring(0, colonIndex).trim();
      final code = raw.substring(colonIndex + 1).trim();
      final translated = map[code] ?? code;
      return field.isEmpty ? translated : '$field: $translated';
    }

    return map[raw] ?? raw;
  }
}
