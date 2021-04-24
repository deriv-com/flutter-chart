// @dart=2.9

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';

/// Model class to hold visible entries of [DataSeries] and keep track of their
/// [startIndex] and [endIndex] indices.
class VisibleEntries<T> {
  /// Initializes.
  const VisibleEntries(this.entries, this.startIndex, this.endIndex);

  /// Initializes an empty visible entries.
  VisibleEntries.empty() : this(<T>[], -1, -1);

  /// Whether visible entries are empty.
  bool get isEmpty => entries.isEmpty;

  /// Whether visible entries are NOT empty.
  bool get isNotEmpty => entries.isNotEmpty;

  /// Visible entries.
  final List<T> entries;

  /// Start index of visible entries.
  final int startIndex;

  /// End index of visible entries.
  final int endIndex;

  /// First item in visible entries.
  T get first => entries.first;

  /// Last item in visible entries.
  T get last => entries.last;

  /// The length of [entries].
  int get length => entries.length;
}
