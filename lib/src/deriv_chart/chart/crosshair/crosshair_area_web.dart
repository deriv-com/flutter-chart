import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Place this area on top of the chart to display candle/point details on longpress.
class CrosshairAreaWeb extends StatefulWidget {
  /// Initializes a  widget to display candle/point details on longpress in a chart.
  const CrosshairAreaWeb({
    required this.mainSeries,
    required this.epochFromCanvasX,
    required this.quoteFromCanvasY,
    this.quoteLabelsTouchAreaWidth = 70,
    this.showCrosshairCursor = true,
    this.pipSize = 4,
    Key? key,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
  }) : super(key: key);

  /// The main series of the chart.
  final Series mainSeries;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  /// Width of the touch area for vertical zoom (on top of quote labels).
  final double quoteLabelsTouchAreaWidth;

  /// Whether the crosshair cursor should be shown or not.
  final bool showCrosshairCursor;

  /// Conversion function for converting chart's canvas' X position to epoch.
  final int Function(double) epochFromCanvasX;

  /// Conversion function for converting chart's canvas' Y position to quote.
  final double Function(double) quoteFromCanvasY;

  /// Called on longpress to show candle/point details.
  final VoidCallback? onCrosshairAppeared;

  /// Called when candle or point is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHoverCallback? onCrosshairHover;

  @override
  _CrosshairAreaWebState createState() => _CrosshairAreaWebState();
}

class _CrosshairAreaWebState extends State<CrosshairAreaWeb> {
  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        right: widget.quoteLabelsTouchAreaWidth,
        child: MouseRegion(
          cursor: widget.showCrosshairCursor
              ? SystemMouseCursors.precise
              : SystemMouseCursors.basic,
          child: const SizedBox.expand(),
          onExit: (PointerExitEvent ev) =>
              widget.onCrosshairDisappeared?.call(),
          onHover: (PointerHoverEvent ev) {
            if (widget.onCrosshairHover == null) {
              return;
            }

            final double quote = widget.quoteFromCanvasY(ev.localPosition.dy);
            final int epoch = widget.epochFromCanvasX(ev.localPosition.dx);
            widget.onCrosshairHover
                ?.call(ev, epoch, quote.toStringAsFixed(widget.pipSize));
          },
        ),
      );
}
