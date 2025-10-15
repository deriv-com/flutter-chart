import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_end_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// A specialized painter for rendering digit contract markers on financial charts.
///
/// `DigitMarkerIconPainter` extends the abstract `MarkerGroupIconPainter` class to provide
/// specific rendering logic for digit-based contracts. Digit contracts are a type of
/// financial contract where the outcome depends on the last digit of the price at a
/// specific time.
///
/// This painter visualizes various aspects of digit contracts on the chart, including:
/// - The starting point of the contract
/// - Individual price ticks with their last digit highlighted
/// - The exit/end point of the contract
///
/// The painter uses different visual representations for different marker types:
/// - Start markers are shown as location pins with optional labels
/// - Tick markers are shown as circles with the last digit of the price inside
/// - Exit markers are shown as flag icons with the last digit of the price
///
/// This class is part of the chart's visualization pipeline and works in conjunction
/// with `MarkerGroupPainter` to render marker groups on the chart canvas.
class DigitMarkerIconPainter extends MarkerGroupIconPainter {
  /// Creates a new `DigitMarkerIconPainter` instance with the specified precision.
  ///
  /// The `pipSize` parameter determines the number of decimal places to display
  /// when rendering price values. This affects how the last digit is extracted and
  /// displayed in tick markers.
  ///
  /// @param pipSize The number of decimal places to display for price values.
  ///                Default is 4, which means prices will be shown with 4 decimal places.
  DigitMarkerIconPainter({this.pipSize = 4});

  /// The number of decimal places to display for price values.
  ///
  /// This value determines how many decimal places are shown when rendering price
  /// values on the chart. It affects how the last digit is extracted and displayed
  /// in tick markers.
  ///
  /// For example, with a pipSize of 4:
  /// - A price of 1.23456 would be displayed as 1.2346 (rounded)
  /// - The last digit extracted would be 6
  int pipSize;

  /// Renders a group of digit contract markers on the chart canvas.
  ///
  /// This method is called by the chart's rendering system to paint a group of
  /// related markers (representing a single digit contract) on the canvas. It:
  /// 1. Converts marker positions from market data (epoch/quote) to canvas coordinates
  /// 2. Calculates the opacity based on marker positions
  /// 3. Delegates the rendering of individual markers to specialized methods
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param markerGroup The group of markers to render.
  /// @param epochToX A function that converts epoch timestamps to X coordinates.
  /// @param quoteToY A function that converts price quotes to Y coordinates.
  /// @param painterProps Properties that affect how markers are rendered.
  /// @param animationInfo Information about any ongoing animations.
  @override
  void paintMarkerGroup(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
    AnimationInfo animationInfo,
  ) {
    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

      if (marker.markerType != null) {
        points[marker.markerType!] = center;
      }
    }

    final Offset? startPoint = points[MarkerType.start];
    final Offset? exitPoint = points[MarkerType.exit];
    final Offset? endPoint = points[MarkerType.exitSpot];

    double opacity = 1;

    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center = points[marker.markerType!]!;
      YAxisConfig.instance.yAxisClipping(canvas, size, () {
        _drawMarker(canvas, size, theme, marker, center, markerGroup.style,
            painterProps.zoom, opacity, markerGroup.props);
      });
    }
  }

  /// Renders an individual marker based on its type.
  ///
  /// This private method handles the rendering of different types of markers
  /// (start, exit, tick) with their specific visual representations. It delegates
  /// to specialized methods for each marker type.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  void _drawMarker(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      ChartMarker marker,
      Offset anchor,
      MarkerStyle style,
      double zoom,
      double opacity,
      MarkerProps props) {
    switch (marker.markerType) {
      case MarkerType.startTime:
        paintStartLine(canvas, size, marker, anchor, style, theme, zoom, props);
        break;

      case MarkerType.start:
        _drawStartPoint(
            canvas, size, theme, marker, anchor, style, zoom, opacity);
        break;

      case MarkerType.exit:
        final Paint paint = Paint()..color = style.backgroundColor;

        paintEndMarker(canvas, theme, anchor - Offset(1, 20 * zoom + 5),
            style.backgroundColor, zoom);

        final Color fontColor = theme.backgroundColor;
        _drawTick(canvas, marker, anchor, style, paint, fontColor, zoom);
        break;
      case MarkerType.tick:
        final Paint paint = Paint()
          ..color = style.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        final Color fontColor = style.backgroundColor;
        _drawTick(canvas, marker, anchor, style, paint, fontColor, zoom);
        break;
      default:
        break;
    }
  }

  /// Renders a tick marker with the last digit of the price.
  ///
  /// This private method draws a circular marker with the last digit of the price
  /// displayed inside it. It's used for both regular tick markers and exit markers.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param paint The paint object to use for drawing.
  /// @param fontColor The color to use for the digit text.
  /// @param zoom The current zoom level of the chart.
  void _drawTick(Canvas canvas, Marker marker, Offset anchor, MarkerStyle style,
      Paint paint, Color fontColor, double zoom) {
    canvas
      ..drawCircle(
        anchor,
        8 * zoom,
        Paint()..color = Colors.white,
      )
      ..drawCircle(
        anchor,
        8 * zoom,
        paint,
      );

    final String lastChar =
        marker.quote.toStringAsFixed(pipSize).characters.last;
    final TextSpan span = TextSpan(
      text: lastChar,
      style: TextStyle(
        fontSize: 10 * zoom,
        color: fontColor,
        fontWeight: FontWeight.bold,
      ),
    );

    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = span
      ..layout();

    painter.paint(
      canvas,
      anchor - Offset(painter.width / 2, painter.height / 2),
    );
  }

  /// Renders the starting point of a digit contract.
  ///
  /// This private method draws a location pin marker at the starting point of
  /// the contract, with an optional text label. The marker's opacity is adjusted
  /// based on its position relative to other markers.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  void _drawStartPoint(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      ChartMarker marker,
      Offset anchor,
      MarkerStyle style,
      double zoom,
      double opacity) {
    if (marker.quote != 0) {
      paintStartMarker(
        canvas,
        anchor - Offset(20 * zoom / 2, 20 * zoom),
        style.backgroundColor.withOpacity(opacity),
        20 * zoom,
      );
    }

    if (marker.text != null) {
      final TextStyle textStyle = TextStyle(
        color: style.backgroundColor.withOpacity(opacity),
        fontSize: style.activeMarkerText.fontSize! * zoom,
        fontWeight: FontWeight.bold,
        backgroundColor: theme.backgroundColor.withOpacity(opacity),
      );

      final TextPainter textPainter = makeTextPainter(marker.text!, textStyle);

      final Offset iconShift =
          Offset(textPainter.width / 2, 20 * zoom + textPainter.height);

      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: anchor - iconShift,
        anchorAlignment: Alignment.centerLeft,
      );
    }
  }
}
