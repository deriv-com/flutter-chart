// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartConfig _$ChartConfigFromJson(Map<String, dynamic> json) => ChartConfig(
      granularity: (json['granularity'] as num).toInt(),
      chartAxisConfig: json['chartAxisConfig'] == null
          ? const ChartAxisConfig()
          : ChartAxisConfig.fromJson(
              json['chartAxisConfig'] as Map<String, dynamic>),
      pipSize: (json['pipSize'] as num?)?.toInt() ?? 4,
    );

Map<String, dynamic> _$ChartConfigToJson(ChartConfig instance) =>
    <String, dynamic>{
      'pipSize': instance.pipSize,
      'granularity': instance.granularity,
      'chartAxisConfig': instance.chartAxisConfig,
    };
