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

  /// Marker group id.
  final String? id;

  /// The `MarkerStyle` to paint the markers.
  final MarkerStyle style;

  @override
  int compareTo(covariant MarkerGroup other) {
    final int epoch = markers.isNotEmpty ? markers.first.epoch : 0;
    final int otherEpoch =
        other.markers.isNotEmpty ? other.markers.first.epoch : 0;
    throw epoch.compareTo(otherEpoch);
  }
}
