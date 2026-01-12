// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overlay_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverlayStyle _$OverlayStyleFromJson(Map<String, dynamic> json) => OverlayStyle(
      labelHeight: (json['labelHeight'] as num?)?.toDouble() ?? 24,
      color: json['color'] == null
          ? const Color(0xFF00A79E)
          : _colorFromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$OverlayStyleToJson(OverlayStyle instance) =>
    <String, dynamic>{
      'labelHeight': instance.labelHeight,
      'color': _colorToJson(instance.color),
    };
