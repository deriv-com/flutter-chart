// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

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

  /// `Field`
  String get labelField {
    return Intl.message(
      'Field',
      name: 'labelField',
      desc: '',
      args: [],
    );
  }

  /// `Period`
  String get labelPeriod {
    return Intl.message(
      'Period',
      name: 'labelPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Search assets`
  String get labelSearchAssets {
    return Intl.message(
      'Search assets',
      name: 'labelSearchAssets',
      desc: '',
      args: [],
    );
  }

  /// `Standard Deviation`
  String get labelStandardDeviation {
    return Intl.message(
      'Standard Deviation',
      name: 'labelStandardDeviation',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get labelType {
    return Intl.message(
      'Type',
      name: 'labelType',
      desc: '',
      args: [],
    );
  }

  /// `No results for "{text}"`
  String informNoResult(Object text) {
    return Intl.message(
      'No results for "$text"',
      name: 'informNoResult',
      desc: '',
      args: [text],
    );
  }

  /// `Try checking your spelling or use a different term`
  String get warnCheckAssetSearchingText {
    return Intl.message(
      'Try checking your spelling or use a different term',
      name: 'warnCheckAssetSearchingText',
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