import 'package:flutter/material.dart';

class AppLocales {
  static const Locale vi = Locale('vi', 'VN');
  static const Locale en = Locale('en', 'US');

  static const Locale defaultLocale = vi;

  static const List<Locale> supportedLocales = [
    vi,
    en,
  ];

  static Locale fromLanguageCode(String? code) {
    switch (code) {
      case 'vi':
        return vi;
      case 'en':
        return en;
      default:
        return defaultLocale;
    }
  }
}
