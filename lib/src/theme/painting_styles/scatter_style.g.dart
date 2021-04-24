// GENERATED CODE - DO NOT MODIFY BY HAND

// @dart=2.9

part of 'scatter_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScatterStyle _$ScatterStyleFromJson(Map<String, dynamic> json) {
  return ScatterStyle(
    color: const ColorConverter().fromJson(json['color'] as int),
    radius: (json['radius'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ScatterStyleToJson(ScatterStyle instance) =>
    <String, dynamic>{
      'color': const ColorConverter().toJson(instance.color),
      'radius': instance.radius,
    };
