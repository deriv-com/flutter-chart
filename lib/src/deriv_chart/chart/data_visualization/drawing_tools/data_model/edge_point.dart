import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edge_point.g.dart';

/// A class that holds epoch and yCoord of the edge points.
@JsonSerializable()
class EdgePoint with EquatableMixin {
  /// Initializes
  const EdgePoint({
    this.epoch = 0,
    this.quote = 0,
  });

  /// Initializes from JSON.
  factory EdgePoint.fromJson(Map<String, dynamic> json) =>
      _$EdgePointFromJson(json);

  /// Serialization to JSON. Serves as value in key-value storage.
  Map<String, dynamic> toJson() => _$EdgePointToJson(this);

  /// Epoch.
  final int epoch;

  /// Quote.
  final double quote;

  /// Returns a copy of this [EdgePoint] with the given values.
  EdgePoint copyWith({
    int? epoch,
    double? quote,
  }) {
    return EdgePoint(
      epoch: epoch ?? this.epoch,
      quote: quote ?? this.quote,
    );
  }

  @override
  List<Object?> get props => <Object>[epoch, quote];
}
