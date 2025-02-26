/// PainterProps
class PainterProps {
  /// Initialize
  PainterProps({
    required this.granularity,
    required this.isMobile,
    required this.msPerPx,
    required this.zoom,
    required this.yAxisWidth,
  });

  /// Specifies zoom of the chart w.r.t to msPerPx.
  final double zoom;

  /// Width of y-axis
  final double yAxisWidth;

  /// Whether it is in mobile mode or not.
  final bool isMobile;

  /// Granulatiry of the chart.
  final int granularity;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;
}
