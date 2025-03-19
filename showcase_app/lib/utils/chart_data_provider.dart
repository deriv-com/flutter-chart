import 'dart:collection';
import 'dart:math';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Utility class for generating sample chart data.
class ChartDataProvider {
  /// Random number generator.
  static final Random _random = Random(42); // Fixed seed for reproducible data

  /// Generate a list of sample ticks.
  static List<Tick> generateTicks({int count = 100}) {
    final List<Tick> ticks = [];
    final baseTimestamp = DateTime.now()
        .subtract(Duration(minutes: count))
        .millisecondsSinceEpoch;
    double lastQuote = 100.0;

    for (int i = 0; i < count; i++) {
      final timestamp = baseTimestamp + i * 60000; // 1 minute intervals
      // Random walk with some volatility
      lastQuote += (_random.nextDouble() - 0.5) * 2.0;
      ticks.add(Tick(
        epoch: timestamp,
        quote: lastQuote,
      ));
    }

    return ticks;
  }

  /// Generate a list of sample candles.
  static List<Candle> generateCandles({int count = 100}) {
    final List<Candle> candles = [];
    final baseTimestamp =
        DateTime.now().subtract(Duration(hours: count)).millisecondsSinceEpoch;
    double lastClose = 100.0;

    for (int i = 0; i < count; i++) {
      final timestamp = baseTimestamp + i * 3600000; // 1 hour intervals

      // Generate realistic OHLC data with random walk
      final change = (_random.nextDouble() - 0.5) * 5.0;
      final open = lastClose;
      final close = open + change;
      final high = max(open, close) + _random.nextDouble() * 2.0;
      final low = min(open, close) - _random.nextDouble() * 2.0;

      lastClose = close;

      candles.add(Candle(
        epoch: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        currentEpoch: timestamp,
      ));
    }

    return candles;
  }

  /// Generate sample barriers.
  static List<ChartAnnotation<ChartObject>> generateBarriers(List<Tick> ticks) {
    if (ticks.isEmpty) return [];

    final lastTick = ticks.last;
    final quotes = ticks.map((tick) => tick.quote).toList();
    final minQuote = quotes.reduce(min);
    final maxQuote = quotes.reduce(max);
    final midQuote = (minQuote + maxQuote) / 2;

    return [
      // Horizontal barrier at the middle price
      HorizontalBarrier(
        midQuote,
        title: 'Middle',
        style: const HorizontalBarrierStyle(
          color: Color(0xFF00A79E),
          isDashed: false,
        ),
        visibility: HorizontalBarrierVisibility.normal,
      ),

      // Vertical barrier at a random tick
      VerticalBarrier.onTick(
        ticks[ticks.length ~/ 2],
        title: 'Mid-point',
        longLine: true,
        style: const VerticalBarrierStyle(
          color: Color(0xFFFF6444),
          isDashed: true,
        ),
      ),

      // Tick indicator at the last tick
      TickIndicator(
        lastTick,
        style: const HorizontalBarrierStyle(
          color: Color(0xFFFF6444),
          labelShape: LabelShape.pentagon,
          hasBlinkingDot: true,
          hasArrow: false,
        ),
        visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
      ),
    ];
  }

  /// Generate sample markers.
  static MarkerSeries generateMarkers(List<Tick> ticks) {
    if (ticks.isEmpty)
      return MarkerSeries(SplayTreeSet<Marker>(),
          markerIconPainter: MultipliersMarkerIconPainter());

    final markers = SplayTreeSet<Marker>();

    // Add some up and down markers at strategic points
    for (int i = 10; i < ticks.length; i += 20) {
      final direction =
          i % 40 == 10 ? MarkerDirection.up : MarkerDirection.down;
      markers.add(Marker(
        direction: direction,
        epoch: ticks[i].epoch,
        quote: ticks[i].quote,
        onTap: () {},
      ));
    }

    return MarkerSeries(markers,
        markerIconPainter: MultipliersMarkerIconPainter());
  }
}
