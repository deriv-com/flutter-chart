import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/dpo_indicator/dpo_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/roc/roc_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/smi/smi_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/gator/gator_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/macd_indicator/macd_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';
import 'adx/adx_indicator_config.dart';
import 'alligator/alligator_indicator_config.dart';
import 'bollinger_bands/bollinger_bands_indicator_config.dart';
import 'callbacks.dart';
import 'commodity_channel_index/cci_indicator_config.dart';
import 'donchian_channel/donchian_channel_indicator_config.dart';
import 'fcb_indicator/fcb_indicator_config.dart';
import 'ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'indicator_item.dart';
import 'ma_env_indicator/ma_env_indicator_config.dart';
import 'ma_indicator/ma_indicator_config.dart';
import 'parabolic_sar/parabolic_sar_indicator_config.dart';
import 'rainbow_indicator/rainbow_indicator_config.dart';
import 'rsi/rsi_indicator_config.dart';
import 'williams_r/williams_r_indicator_config.dart';
import 'zigzag_indicator/zigzag_indicator_config.dart';

/// Indicator config
@immutable
abstract class IndicatorConfig extends AddOnConfig {
  /// Initializes
  const IndicatorConfig({bool isOverlay = true}) : super(isOverlay: isOverlay);

  /// Creates a concrete indicator config from JSON.
  factory IndicatorConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(nameKey)) {
      throw ArgumentError.value(json, 'json', 'Missing indicator name.');
    }

    switch (json[nameKey]) {
      case MAIndicatorConfig.name:
        return MAIndicatorConfig.fromJson(json);
      case MAEnvIndicatorConfig.name:
        return MAEnvIndicatorConfig.fromJson(json);
      case BollingerBandsIndicatorConfig.name:
        return BollingerBandsIndicatorConfig.fromJson(json);
      case DonchianChannelIndicatorConfig.name:
        return DonchianChannelIndicatorConfig.fromJson(json);
      case AlligatorIndicatorConfig.name:
        return AlligatorIndicatorConfig.fromJson(json);
      case RainbowIndicatorConfig.name:
        return RainbowIndicatorConfig.fromJson(json);
      case ZigZagIndicatorConfig.name:
        return ZigZagIndicatorConfig.fromJson(json);
      case IchimokuCloudIndicatorConfig.name:
        return IchimokuCloudIndicatorConfig.fromJson(json);
      case ParabolicSARConfig.name:
        return ParabolicSARConfig.fromJson(json);
      case RSIIndicatorConfig.name:
        return RSIIndicatorConfig.fromJson(json);
      case CCIIndicatorConfig.name:
        return CCIIndicatorConfig.fromJson(json);
      case FractalChaosBandIndicatorConfig.name:
        return FractalChaosBandIndicatorConfig.fromJson(json);
      case StochasticOscillatorIndicatorConfig.name:
        return StochasticOscillatorIndicatorConfig.fromJson(json);
      case ADXIndicatorConfig.name:
        return ADXIndicatorConfig.fromJson(json);
      case DPOIndicatorConfig.name:
        return DPOIndicatorConfig.fromJson(json);
      case AwesomeOscillatorIndicatorConfig.name:
        return AwesomeOscillatorIndicatorConfig.fromJson(json);
      case SMIIndicatorConfig.name:
        return SMIIndicatorConfig.fromJson(json);
      case WilliamsRIndicatorConfig.name:
        return WilliamsRIndicatorConfig.fromJson(json);
      case MACDIndicatorConfig.name:
        return MACDIndicatorConfig.fromJson(json);
      case AroonIndicatorConfig.name:
        return AroonIndicatorConfig.fromJson(json);
      case GatorIndicatorConfig.name:
        return GatorIndicatorConfig.fromJson(json);
      case ROCIndicatorConfig.name:
        return ROCIndicatorConfig.fromJson(json);
      // Add new indicators here.
      default:
        throw ArgumentError.value(json, 'json', 'Unidentified indicator name.');
    }
  }

  /// Key of indicator name property in JSON.
  static const String nameKey = 'name';

  /// Indicators supported field types
  static final Map<String, FieldIndicatorBuilder> supportedFieldTypes =
      <String, FieldIndicatorBuilder>{
    'close': (IndicatorInput indicatorInput) =>
        CloseValueIndicator<Tick>(indicatorInput),
    'high': (IndicatorInput indicatorInput) =>
        HighValueIndicator<Tick>(indicatorInput),
    'low': (IndicatorInput indicatorInput) =>
        LowValueIndicator<Tick>(indicatorInput),
    'open': (IndicatorInput indicatorInput) =>
        OpenValueIndicator<Tick>(indicatorInput),
    'Hl/2': (IndicatorInput indicatorInput) =>
        HL2Indicator<Tick>(indicatorInput),
    'HlC/3': (IndicatorInput indicatorInput) =>
        HLC3Indicator<Tick>(indicatorInput),
    'HlCC/4': (IndicatorInput indicatorInput) =>
        HLCC4Indicator<Tick>(indicatorInput),
    'OHlC/4': (IndicatorInput indicatorInput) =>
        OHLC4Indicator<Tick>(indicatorInput),
  };

  /// Creates indicator [Series] for the given [indicatorInput].
  Series getSeries(IndicatorInput indicatorInput);

  /// Creates indicator UI.
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  );
}
