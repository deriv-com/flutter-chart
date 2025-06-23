import 'package:equatable/equatable.dart';

/// Class that represents the range of epoch from left to right.
/// Can use to represent the x-axis range on the chart.
class EpochRange with EquatableMixin {
  /// Initializes.
  EpochRange({required this.leftEpoch, required this.rightEpoch});

  /// The left-most epoch.
  final int leftEpoch;

  /// The right-most epoch.
  final int rightEpoch;

  @override
  List<Object?> get props => [leftEpoch, rightEpoch];
}

/// Class that represents the range of quotes from top to bottom.
/// Can use to represent the Y-axis range of the chart.
class QuoteRange with EquatableMixin {
  /// Initializes.
  QuoteRange({required this.topQuote, required this.bottomQuote});

  /// The top-most quote.
  final double topQuote;

  /// The bottom-most quote.
  final double bottomQuote;

  @override
  List<Object?> get props => [topQuote, bottomQuote];
}
