import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/core/crosshair_area.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/core/crosshair_variant.dart';
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
    this.crosshairBehaviour,
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

  /// The behaviour implementation that defines how the crosshair should be displayed.
  ///
  /// If not provided, a default behaviour will be created based on the chart's main series
  /// and the specified crosshair variant. This allows for customization of the crosshair
  /// appearance and behaviour when needed.
  final CrosshairBehaviour? crosshairBehaviour;

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  @override
  Widget build(BuildContext context) {
    // If showCrosshair is false, don't show the crosshair at all
    if (!showCrosshair) {
      return const SizedBox.shrink();
    }
    final _crosshairBehaviour = crosshairBehaviour ??
        mainSeries.getCrosshairStrategyContext().getBehaviour(crosshairVariant);

    return ValueListenableBuilder<CrosshairState>(
      valueListenable: crosshairController,
      builder: (context, state, _) {
        if (!state.isVisible || state.crosshairTick == null) {
          return const SizedBox.shrink();
        }
        return AnimatedBuilder(
          animation: crosshairZoomOutAnimation,
          builder: (_, __) {
            return RepaintBoundary(
              child: CrosshairArea(
                mainSeries: mainSeries,
                pipSize: pipSize,
                quoteToCanvasY: quoteToCanvasY,
                crosshairTick: state.crosshairTick,
                cursorPosition: state.cursorPosition,
                animationDuration: crosshairController.animationDuration,
                crosshairBehaviour: _crosshairBehaviour,
              ),
            );
          },
        );
      },
    );
  }
}
