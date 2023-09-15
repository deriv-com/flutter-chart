// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tick.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tick _$TickFromJson(Map<String, dynamic> json) => Tick(
      epoch: json['epoch'] as int,
      quote: (json['quote'] as num).toDouble(),
    );

Map<String, dynamic> _$TickToJson(Tick instance) => <String, dynamic>{
      'epoch': instance.epoch,
      'quote': instance.quote,
    };
