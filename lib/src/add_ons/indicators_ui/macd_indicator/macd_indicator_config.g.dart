// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macd_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MACDIndicatorConfig _$MACDIndicatorConfigFromJson(Map<String, dynamic> json) =>
    MACDIndicatorConfig(
      fastMAPeriod: json['fastMAPeriod'] as int? ?? 12,
      slowMAPeriod: json['slowMAPeriod'] as int? ?? 26,
      signalPeriod: json['signalPeriod'] as int? ?? 9,
      barStyle: json['barStyle'] == null
          ? const BarStyle()
          : BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      signalLineStyle: json['signalLineStyle'] == null
          ? const LineStyle(color: Colors.redAccent)
          : LineStyle.fromJson(json['signalLineStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$MACDIndicatorConfigToJson(
        MACDIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'fastMAPeriod': instance.fastMAPeriod,
      'slowMAPeriod': instance.slowMAPeriod,
      'signalPeriod': instance.signalPeriod,
      'barStyle': instance.barStyle,
      'lineStyle': instance.lineStyle,
      'signalLineStyle': instance.signalLineStyle,
    };
