// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adx_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ADXIndicatorConfig _$ADXIndicatorConfigFromJson(Map<String, dynamic> json) =>
    ADXIndicatorConfig(
      period: json['period'] as int? ?? 14,
      smoothingPeriod: json['smoothingPeriod'] as int? ?? 14,
      showSeries: json['showSeries'] as bool? ?? true,
      showChannelFill: json['showChannelFill'] as bool? ?? false,
      showHistogram: json['showHistogram'] as bool? ?? false,
      showShading: json['showShading'] as bool? ?? false,
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      positiveLineStyle: json['positiveLineStyle'] == null
          ? const LineStyle(color: Colors.green)
          : LineStyle.fromJson(
              json['positiveLineStyle'] as Map<String, dynamic>),
      negativeLineStyle: json['negativeLineStyle'] == null
          ? const LineStyle(color: Colors.red)
          : LineStyle.fromJson(
              json['negativeLineStyle'] as Map<String, dynamic>),
      barStyle: json['barStyle'] == null
          ? const BarStyle()
          : BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$ADXIndicatorConfigToJson(ADXIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'showChannelFill': instance.showChannelFill,
      'showHistogram': instance.showHistogram,
      'showShading': instance.showShading,
      'showSeries': instance.showSeries,
      'lineStyle': instance.lineStyle,
      'positiveLineStyle': instance.positiveLineStyle,
      'negativeLineStyle': instance.negativeLineStyle,
      'barStyle': instance.barStyle,
    };
