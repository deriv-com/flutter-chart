import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_area.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'crosshair_controller.dart';

/// A widget that displays the crosshair on the chart.
class CrosshairWidget extends StatelessWidget {
  /// Creates a new crosshair widget.
  const CrosshairWidget({
    required this.mainSeries,
    required this.quoteToCanvasY,
    required this.pipSize,
    required this.crosshairController,
    required this.crosshairZoomOutAnimation,
    required this.crosshairVariant,
    this.showCrosshair = true,
    super.key,
  });

  /// The main data series of the chart.
  final DataSeries<Tick> mainSeries;

  /// Function to convert quote values to canvas Y coordinates.
  final double Function(double) quoteToCanvasY;

  /// Number of decimal digits when showing prices in the crosshair.
  final int pipSize;

  /// The controller for the crosshair.
  final CrosshairController crosshairController;

  /// Animation for zooming out the crosshair.
  final Animation<double> crosshairZoomOutAnimation;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  @override
  Widget build(BuildContext context) {
    // If showCrosshair is false, don't show the crosshair at all
    if (!showCrosshair) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<CrosshairState>(
      valueListenable: crosshairController,
      builder: (context, state, _) {
        if (!state.isVisible || state.crosshairTick == null) {
          return const SizedBox.shrink();
        }
        return AnimatedBuilder(
          animation: crosshairZoomOutAnimation,
          builder: (BuildContext context, _) {
            return RepaintBoundary(
              child: CrosshairArea(
                mainSeries: mainSeries,
                pipSize: pipSize,
                quoteToCanvasY: quoteToCanvasY,
                crosshairTick: state.crosshairTick,
                cursorPosition: state.cursorPosition,
                animationDuration: crosshairController.animationDuration,
                crosshairVariant: crosshairVariant,
              ),
            );
          },
        );
      },
    );
  }
}
