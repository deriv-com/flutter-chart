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

  /// `Channel Fill`
  String get labelChannelFill {
    return Intl.message(
      'Channel Fill',
      name: 'labelChannelFill',
      desc: '',
      args: [],
    );
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

  /// `Conversion Line Period`
  String get labelConversionLinePeriod {
    return Intl.message(
      'Conversion Line Period',
      name: 'labelConversionLinePeriod',
      desc: '',
      args: [],
    );
  }

  /// `Base Line Period`
  String get labelBaseLinePeriod {
    return Intl.message(
      'Base Line Period',
      name: 'labelBaseLinePeriod',
      desc: '',
      args: [],
    );
  }

  /// `Leading Span B Period`
  String get labelSpanBPeriod {
    return Intl.message(
      'Leading Span B Period',
      name: 'labelSpanBPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Lagging Span Offset`
  String get labelLaggingSpanOffset {
    return Intl.message(
      'Lagging Span Offset',
      name: 'labelLaggingSpanOffset',
      desc: '',
      args: [],
    );
  }

  /// `Jaw Period`
  String get labelJawPeriod {
    return Intl.message(
      'Jaw Period',
      name: 'labelJawPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Teeth Period`
  String get labelTeethPeriod {
    return Intl.message(
      'Teeth Period',
      name: 'labelTeethPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Lips Period`
  String get labelLipsPeriod {
    return Intl.message(
      'Lips Period',
      name: 'labelLipsPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Offset`
  String get labelOffset {
    return Intl.message(
      'Offset',
      name: 'labelOffset',
      desc: '',
      args: [],
    );
  }

  /// `Jaw Offset`
  String get labelJawOffset {
    return Intl.message(
      'Jaw Offset',
      name: 'labelJawOffset',
      desc: '',
      args: [],
    );
  }

  /// `Teeth Offset`
  String get labelTeethOffset {
    return Intl.message(
      'Teeth Offset',
      name: 'labelTeethOffset',
      desc: '',
      args: [],
    );
  }

  /// `Lips Offset`
  String get labelLipsOffset {
    return Intl.message(
      'Lips Offset',
      name: 'labelLipsOffset',
      desc: '',
      args: [],
    );
  }

  /// `High Period`
  String get labelHighPeriod {
    return Intl.message(
      'High Period',
      name: 'labelHighPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Low Period`
  String get labelLowPeriod {
    return Intl.message(
      'Low Period',
      name: 'labelLowPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Shift`
  String get labelShift {
    return Intl.message(
      'Shift',
      name: 'labelShift',
      desc: '',
      args: [],
    );
  }

  /// `Bands Count`
  String get labelBandsCount {
    return Intl.message(
      'Bands Count',
      name: 'labelBandsCount',
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

  /// `Shift Type`
  String get labelShiftType {
    return Intl.message(
      'Shift Type',
      name: 'labelShiftType',
      desc: '',
      args: [],
    );
  }

  /// `Distance`
  String get labelDistance {
    return Intl.message(
      'Distance',
      name: 'labelDistance',
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