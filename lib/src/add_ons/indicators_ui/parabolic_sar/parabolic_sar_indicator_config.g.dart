// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parabolic_sar_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParabolicSARConfig _$ParabolicSARConfigFromJson(Map<String, dynamic> json) {
  return ParabolicSARConfig(
    id: json['id'] as String?,
    minAccelerationFactor: (json['minAccelerationFactor'] as num).toDouble(),
    maxAccelerationFactor: (json['maxAccelerationFactor'] as num).toDouble(),
    scatterStyle:
        ScatterStyle.fromJson(json['scatterStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ParabolicSARConfigToJson(ParabolicSARConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'minAccelerationFactor': instance.minAccelerationFactor,
      'maxAccelerationFactor': instance.maxAccelerationFactor,
      'scatterStyle': instance.scatterStyle,
    };
