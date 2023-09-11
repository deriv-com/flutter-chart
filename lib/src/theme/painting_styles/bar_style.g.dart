// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarStyle _$BarStyleFromJson(Map<String, dynamic> json) => BarStyle(
      positiveColor: json['positiveColor'] == null
          ? const Color(0xFF4CAF50)
          : const ColorConverter().fromJson(json['positiveColor'] as int),
      negativeColor: json['negativeColor'] == null
          ? const Color(0xFFCC2E3D)
          : const ColorConverter().fromJson(json['negativeColor'] as int),
    );

Map<String, dynamic> _$BarStyleToJson(BarStyle instance) => <String, dynamic>{
      'positiveColor': const ColorConverter().toJson(instance.positiveColor),
      'negativeColor': const ColorConverter().toJson(instance.negativeColor),
    };
