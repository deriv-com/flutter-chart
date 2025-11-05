# Basic Usage

This guide will walk you through the basic usage of the Deriv Chart library, showing you how to create different types of charts and customize them.

## Creating a Simple Chart

To create a basic chart, you need to:

1. Import the library
2. Create a data series
3. Pass the data series to the Chart widget

Here's a simple example of a line chart:

```dart
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

class SimpleChartExample extends StatelessWidget {
  const SimpleChartExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create sample data
    final ticks = [
      Tick(epoch: DateTime.now().subtract(const Duration(minutes: 5)), quote: 100),
      Tick(epoch: DateTime.now().subtract(const Duration(minutes: 4)), quote: 120),
      Tick(epoch: DateTime.now().subtract(const Duration(minutes: 3)), quote: 110),
      Tick(epoch: DateTime.now().subtract(const Duration(minutes: 2)), quote: 130),
      Tick(epoch: DateTime.now().subtract(const Duration(minutes: 1)), quote: 125),
      Tick(epoch: DateTime.now(), quote: 140),
    ];

    // Create the chart
    return SizedBox(
      height: 300,
      child: Chart(
        mainSeries: LineSeries(ticks),
        pipSize: 2, // Number of decimal places for price values
      ),
    );
  }
}
```

## Chart Data Types

The Deriv Chart library supports two main types of data:

1. **Tick Data**: Simple time-price pairs, used for line charts
2. **OHLC Data**: Open-High-Low-Close data, used for candlestick and OHLC charts

### Tick Data Example

```dart
final ticks = [
  Tick(epoch: DateTime.now().subtract(const Duration(minutes: 5)), quote: 100),
  Tick(epoch: DateTime.now().subtract(const Duration(minutes: 4)), quote: 120),
  // More ticks...
];
```

### OHLC (Candle) Data Example

```dart
final candles = [
  Candle(
    epoch: DateTime.now().subtract(const Duration(minutes: 5)),
    open: 100,
    high: 120,
    low: 95,
    close: 110,
  ),
  Candle(
    epoch: DateTime.now().subtract(const Duration(minutes: 4)),
    open: 110,
    high: 130,
    low: 105,
    close: 125,
  ),
  // More candles...
];
```

## Chart Types

The Deriv Chart library supports several chart types:

### Line Chart

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  granularity: 60000, // 60000 milliseconds (1 minute) interval
)
```

### Candlestick Chart

```dart
Chart(
  mainSeries: CandleSeries(candles),
  pipSize: 2,
  granularity: 60000, // 60000 milliseconds (1 minute) interval per candle
)
```

### OHLC Chart

```dart
Chart(
  mainSeries: OHLCSeries(candles),
  pipSize: 2,
  granularity: 60000, // 60000 milliseconds (1 minute) interval per candle
)
```

### Hollow Candlestick Chart

```dart
Chart(
  mainSeries: HollowCandleSeries(candles),
  pipSize: 2,
  granularity: 60000, // 60000 milliseconds (1 minute) interval per candle
)
```

## Basic Customization

### Styling the Chart

You can customize the appearance of your charts by providing style objects:

```dart
Chart(
  mainSeries: CandleSeries(
    candles,
    style: CandleStyle(
      positiveColor: Colors.green,
      negativeColor: Colors.red,
      neutralColor: Colors.grey,
    ),
  ),
  pipSize: 2,
)
```

### Adding Annotations

You can add horizontal or vertical barriers to mark specific price levels or time points:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    HorizontalBarrier(
      125.0,
      title: 'Resistance',
      style: HorizontalBarrierStyle(
        color: Colors.red,
        isDashed: true,
      ),
    ),
    VerticalBarrier(
      ticks[2].epoch,
      title: 'Event',
      style: VerticalBarrierStyle(
        color: Colors.blue,
        isDashed: false,
      ),
    ),
  ],
)
```

### Adding Tick Indicators

Tick indicators are special annotations that highlight specific data points:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    TickIndicator(ticks.last),
  ],
)
```

## Handling User Interactions

### Listening to Visible Area Changes

You can listen to changes in the visible area of the chart (scrolling and zooming):

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
    print('Visible area changed: $leftEpoch to $rightEpoch');
    // Load more data if needed
  },
)
```

### Listening to Crosshair Events

You can listen to when the crosshair appears on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  onCrosshairAppeared: () {
    print('Crosshair appeared');
    // Provide haptic feedback or update UI
  },
)
```

## Next Steps

Now that you understand the basics of using the Deriv Chart library, you can explore:

- [Chart Types](chart_types.md) - Learn more about different chart types
- [Configuration](configuration.md) - Discover more configuration options
- [Advanced Features](advanced_features.md) - Learn about technical indicators, annotations, markers, and drawing tools