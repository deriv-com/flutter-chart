/// PainterProps
class PainterProps {
  /// Initialize
  PainterProps({
    required this.granularity,
    required this.msPerPx,
    required this.zoom,
  });

  /// Specifies zoom of the chart w.r.t to msPerPx.
  final double zoom;

  /// Granulatiry of the chart.
  final int granularity;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;
}
