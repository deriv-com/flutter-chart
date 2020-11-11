// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class ChartLocalization {
  ChartLocalization();
  
  static ChartLocalization current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<ChartLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      ChartLocalization.current = ChartLocalization();
      
      return ChartLocalization.current;
    });
  } 

  static ChartLocalization of(BuildContext context) {
    return Localizations.of<ChartLocalization>(context, ChartLocalization);
  }

  /// `Test Content`
  String get testContent {
    return Intl.message(
      'Test Content',
      name: 'testContent',
      desc: '',
      args: [],
    );
  }

  /// `Test 2 Content`
  String get test2Content {
    return Intl.message(
      'Test 2 Content',
      name: 'test2Content',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<ChartLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<ChartLocalization> load(Locale locale) => ChartLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}