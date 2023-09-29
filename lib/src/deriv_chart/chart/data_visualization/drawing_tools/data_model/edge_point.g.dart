// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdgePoint _$EdgePointFromJson(Map<String, dynamic> json) => EdgePoint(
      epoch: json['epoch'] as int? ?? 0,
      quote: (json['quote'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$EdgePointToJson(EdgePoint instance) => <String, dynamic>{
      'epoch': instance.epoch,
      'quote': instance.quote,
    };
