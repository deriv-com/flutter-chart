import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';

/// Chart open position marker.
class MarkerGroup implements Comparable<MarkerGroup> {
  /// Initialize marker group
  MarkerGroup(
    this.markers, {
    this.id,
    this.style = const MarkerStyle(),
  });

  /// Marker entries.
  final List<Marker> markers;

  /// Marker id.
  final String? id;

  /// The `MarkerStyle` to paint the marker with.
  final MarkerStyle style;

  @override
  int compareTo(MarkerGroup other) {
    throw markers.first.epoch.compareTo(other.markers.first.epoch);
  }
}
