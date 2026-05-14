import 'package:flutter/material.dart';

class AppLocaleController {
  AppLocaleController._();

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('ml'));

  static void setLocale(Locale locale) {
    localeNotifier.value = locale;
  }
}
