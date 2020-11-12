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

  /// `Search assets`
  String get search_assets_347920236 {
    return Intl.message(
      'Search assets',
      name: 'search_assets_347920236',
      desc: '',
      args: [],
    );
  }

  /// `No results for '{text}' `
  String no_results_for_text_214859493(Object text) {
    return Intl.message(
      'No results for \'$text\' ',
      name: 'no_results_for_text_214859493',
      desc: '',
      args: [text],
    );
  }

  /// `Try checking your spelling or use a different term`
  String get try_checking_your_sp_205400823 {
    return Intl.message(
      'Try checking your spelling or use a different term',
      name: 'try_checking_your_sp_205400823',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<ChartLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
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