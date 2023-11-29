// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parabolic_sar_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParabolicSARConfig _$ParabolicSARConfigFromJson(Map<String, dynamic> json) =>
    ParabolicSARConfig(
      minAccelerationFactor:
          (json['minAccelerationFactor'] as num?)?.toDouble() ?? 0.02,
      maxAccelerationFactor:
          (json['maxAccelerationFactor'] as num?)?.toDouble() ?? 0.2,
      scatterStyle: json['scatterStyle'] == null
          ? const ScatterStyle()
          : ScatterStyle.fromJson(json['scatterStyle'] as Map<String, dynamic>),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$ParabolicSARConfigToJson(ParabolicSARConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'minAccelerationFactor': instance.minAccelerationFactor,
      'maxAccelerationFactor': instance.maxAccelerationFactor,
      'scatterStyle': instance.scatterStyle,
    };
