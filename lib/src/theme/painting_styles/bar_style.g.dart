// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarStyle _$BarStyleFromJson(Map<String, dynamic> json) {
  return BarStyle(
    positiveColor:
        const ColorConverter().fromJson(json['positiveColor'] as int),
    negativeColor:
        const ColorConverter().fromJson(json['negativeColor'] as int),
  );
}

Map<String, dynamic> _$BarStyleToJson(BarStyle instance) => <String, dynamic>{
      'positiveColor': const ColorConverter().toJson(instance.positiveColor),
      'negativeColor': const ColorConverter().toJson(instance.negativeColor),
    };
