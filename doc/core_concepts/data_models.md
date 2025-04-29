# Data Models

This document explains the key data models used in the Deriv Chart library, their properties, and how they relate to each other.

## Overview

The Deriv Chart library uses several data models to represent financial data and chart elements:

1. **Market Data Models**: Represent financial market data (Tick, Candle)
2. **Series Models**: Represent data series for visualization (LineSeries, CandleSeries)
3. **Annotation Models**: Represent chart annotations (Barriers, TickIndicator)
4. **Marker Models**: Represent point markers on the chart
5. **Indicator Models**: Represent technical indicators

## Market Data Models

### Tick

The `Tick` class represents a single price point at a specific time:

```dart
class Tick {
  /// The timestamp of the tick
  final DateTime epoch;
  
  /// The price value
  final double quote;
  
  Tick({
    required this.epoch,
    required this.quote,
  });
}
```

Ticks are used for:
- Line charts
- Real-time price updates
- Entry/exit points
- Tick indicators

### Candle (OHLC)

The `Candle` class represents price movement over a time period with open, high, low, and close values:

```dart
class Candle {
  /// The timestamp of the candle (typically the opening time)
  final DateTime epoch;
  
  /// The opening price
  final double open;
  
  /// The highest price during the period
  final double high;
  
  /// The lowest price during the period
  final double low;
  
  /// The closing price
  final double close;
  
  Candle({
    required this.epoch,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
  
  /// Whether the candle is bullish (close > open)
  bool get isBullish => close > open;
  
  /// Whether the candle is bearish (close < open)
  bool get isBearish => close < open;
}
```

Candles are used for:
- Candlestick charts
- OHLC charts
- Hollow candlestick charts
- Technical indicators

## Series Models

### Series

`Series` is the base class for all chart series:

```dart
abstract class Series extends ChartData {
  /// Creates a painter for this series
  SeriesPainter createPainter();
  
  /// The minimum value in the visible range
  double get minValue;
  
  /// The maximum value in the visible range
  double get maxValue;
  
  /// Updates the visible range
  void updateVisibleRange(int leftEpoch, int rightEpoch);
}
```

### DataSeries

`DataSeries` extends `Series` to handle sequential data:

```dart
abstract class DataSeries<T> extends Series {
  /// The list of data points
  final List<T> data;
  
  /// The visible data points
  List<T> visibleData = [];
  
  DataSeries(this.data);
  
  /// Updates the visible data based on the visible range
  @override
  void updateVisibleRange(int leftEpoch, int rightEpoch) {
    visibleData = _getVisibleData(leftEpoch, rightEpoch);
  }
  
  /// Gets the data points within the visible range
  List<T> _getVisibleData(int leftEpoch, int rightEpoch);
}
```

### LineSeries

`LineSeries` represents a line chart:

```dart
class LineSeries extends DataSeries<Tick> {
  /// The style of the line
  final LineStyle style;
  
  LineSeries(
    List<Tick> ticks, {
    this.style = const LineStyle(),
  }) : super(ticks);
  
  @override
  SeriesPainter createPainter() => LinePainter(this);
}
```

### CandleSeries

`CandleSeries` represents a candlestick chart:

```dart
class CandleSeries extends DataSeries<Candle> {
  /// The style of the candles
  final CandleStyle style;
  
  CandleSeries(
    List<Candle> candles, {
    this.style = const CandleStyle(),
  }) : super(candles);
  
  @override
  SeriesPainter createPainter() => CandlePainter(this);
}
```

### OHLCSeries

`OHLCSeries` represents an OHLC chart:

```dart
class OHLCSeries extends DataSeries<Candle> {
  /// The style of the OHLC bars
  final OHLCStyle style;
  
  OHLCSeries(
    List<Candle> candles, {
    this.style = const OHLCStyle(),
  }) : super(candles);
  
  @override
  SeriesPainter createPainter() => OHLCPainter(this);
}
```

### HollowCandleSeries

`HollowCandleSeries` represents a hollow candlestick chart:

```dart
class HollowCandleSeries extends DataSeries<Candle> {
  /// The style of the hollow candles
  final HollowCandleStyle style;
  
  HollowCandleSeries(
    List<Candle> candles, {
    this.style = const HollowCandleStyle(),
  }) : super(candles);
  
  @override
  SeriesPainter createPainter() => HollowCandlePainter(this);
}
```

## Annotation Models

### ChartAnnotation

`ChartAnnotation` is the base class for all chart annotations:

```dart
abstract class ChartAnnotation extends Series {
  /// The unique identifier of the annotation
  final String id;
  
  ChartAnnotation({String? id}) : id = id ?? uuid.v4();
  
  /// Creates a chart object for this annotation
  ChartObject createObject();
}
```

### Barrier

`Barrier` is the base class for horizontal and vertical barriers:

```dart
abstract class Barrier extends ChartAnnotation {
  /// The title of the barrier
  final String? title;
  
  Barrier({
    this.title,
    super.id,
  });
}
```

### HorizontalBarrier

`HorizontalBarrier` represents a horizontal line at a specific price level:

```dart
class HorizontalBarrier extends Barrier {
  /// The price level of the barrier
  final double value;
  
  /// The style of the barrier
  final HorizontalBarrierStyle style;
  
  /// The visibility behavior of the barrier
  final HorizontalBarrierVisibility visibility;
  
  HorizontalBarrier(
    this.value, {
    super.title,
    super.id,
    this.style = const HorizontalBarrierStyle(),
    this.visibility = HorizontalBarrierVisibility.normal,
  });
  
  @override
  ChartObject createObject() => BarrierObject(
    value: value,
    epoch: null,
    title: title,
  );
  
  @override
  SeriesPainter createPainter() => HorizontalBarrierPainter(this);
}
```

### VerticalBarrier

`VerticalBarrier` represents a vertical line at a specific timestamp:

```dart
class VerticalBarrier extends Barrier {
  /// The timestamp of the barrier
  final DateTime epoch;
  
  /// The style of the barrier
  final VerticalBarrierStyle style;
  
  VerticalBarrier(
    this.epoch, {
    super.title,
    super.id,
    this.style = const VerticalBarrierStyle(),
  });
  
  @override
  ChartObject createObject() => BarrierObject(
    value: null,
    epoch: epoch,
    title: title,
  );
  
  @override
  SeriesPainter createPainter() => VerticalBarrierPainter(this);
}
```

### TickIndicator

`TickIndicator` is a special type of horizontal barrier that represents a specific tick:

```dart
class TickIndicator extends HorizontalBarrier {
  /// The tick being indicated
  final Tick tick;
  
  TickIndicator(
    this.tick, {
    super.id,
    super.style = const HorizontalBarrierStyle(),
    super.visibility = HorizontalBarrierVisibility.forceToStayOnRange,
  }) : super(
    tick.quote,
    title: tick.quote.toString(),
  );
}
```

## Marker Models

### MarkerSeries

`MarkerSeries` represents a collection of markers on the chart:

```dart
class MarkerSeries extends Series {
  /// The list of markers
  final List<Marker> markers;
  
  /// The active marker (highlighted)
  final ActiveMarker? activeMarker;
  
  /// The entry tick marker
  final Tick? entryTick;
  
  /// The exit tick marker
  final Tick? exitTick;
  
  MarkerSeries(
    this.markers, {
    this.activeMarker,
    this.entryTick,
    this.exitTick,
  });
  
  @override
  SeriesPainter createPainter() => MarkerPainter(this);
}
```

### Marker

`Marker` represents a point marker on the chart:

```dart
class Marker {
  /// The timestamp of the marker
  final DateTime epoch;
  
  /// The price level of the marker
  final double quote;
  
  /// The type of marker (up, down, neutral)
  final MarkerType type;
  
  /// Callback when the marker is tapped
  final VoidCallback? onTap;
  
  Marker({
    required this.epoch,
    required this.quote,
    required this.type,
    this.onTap,
  });
  
  /// Creates an up marker
  factory Marker.up({
    required DateTime epoch,
    required double quote,
    VoidCallback? onTap,
  }) => Marker(
    epoch: epoch,
    quote: quote,
    type: MarkerType.up,
    onTap: onTap,
  );
  
  /// Creates a down marker
  factory Marker.down({
    required DateTime epoch,
    required double quote,
    VoidCallback? onTap,
  }) => Marker(
    epoch: epoch,
    quote: quote,
    type: MarkerType.down,
    onTap: onTap,
  );
}
```

### ActiveMarker

`ActiveMarker` represents a highlighted marker on the chart:

```dart
class ActiveMarker {
  /// The timestamp of the marker
  final DateTime epoch;
  
  /// The price level of the marker
  final double quote;
  
  /// Callback when the marker is tapped
  final VoidCallback? onTap;
  
  /// Callback when the user taps outside the marker
  final VoidCallback? onOutsideTap;
  
  ActiveMarker({
    required this.epoch,
    required this.quote,
    this.onTap,
    this.onOutsideTap,
  });
}
```

## Indicator Models

### IndicatorConfig

`IndicatorConfig` is the base class for all indicator configurations:

```dart
abstract class IndicatorConfig {
  /// The unique identifier of the indicator
  final String id;
  
  /// The name of the indicator
  String get name;
  
  /// Whether the indicator is displayed on the main chart or in a separate chart
  bool get isOverlay;
  
  IndicatorConfig({String? id}) : id = id ?? uuid.v4();
  
  /// Creates a series for this indicator
  Series createSeries(List<Candle> candles);
  
  /// Converts the config to JSON for storage
  Map<String, dynamic> toJson();
  
  /// Creates a config from JSON
  factory IndicatorConfig.fromJson(Map<String, dynamic> json);
}
```

### Moving Average Indicator

Example of a specific indicator configuration:

```dart
class MAIndicatorConfig extends IndicatorConfig {
  /// The period of the moving average
  final int period;
  
  /// The type of moving average
  final MovingAverageType type;
  
  /// The style of the line
  final LineStyle lineStyle;
  
  MAIndicatorConfig({
    required this.period,
    this.type = MovingAverageType.simple,
    this.lineStyle = const LineStyle(),
    super.id,
  });
  
  @override
  String get name => '$type MA ($period)';
  
  @override
  bool get isOverlay => true;
  
  @override
  Series createSeries(List<Candle> candles) => MASeries(
    candles,
    period: period,
    type: type,
    lineStyle: lineStyle,
  );
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'MA',
    'period': period,
    'maType': type.index,
    'lineStyle': lineStyle.toJson(),
  };
  
  factory MAIndicatorConfig.fromJson(Map<String, dynamic> json) => MAIndicatorConfig(
    id: json['id'],
    period: json['period'],
    type: MovingAverageType.values[json['maType']],
    lineStyle: LineStyle.fromJson(json['lineStyle']),
  );
}
```

## Drawing Tool Models

### DrawingToolConfig

`DrawingToolConfig` is the base class for all drawing tool configurations:

```dart
abstract class DrawingToolConfig {
  /// The unique identifier of the drawing tool
  final String id;
  
  /// The name of the drawing tool
  String get name;
  
  DrawingToolConfig({String? id}) : id = id ?? uuid.v4();
  
  /// Creates a drawing for this tool
  Drawing createDrawing();
  
  /// Converts the config to JSON for storage
  Map<String, dynamic> toJson();
  
  /// Creates a config from JSON
  factory DrawingToolConfig.fromJson(Map<String, dynamic> json);
}
```

### InteractableDrawing

`InteractableDrawing` is the base class for all interactive drawing tools:

```dart
abstract class InteractableDrawing {
  /// The current state of the drawing
  DrawingToolState state;
  
  /// The style of the drawing
  final DrawingPaintStyle style;
  
  InteractableDrawing({
    this.state = DrawingToolState.normal,
    required this.style,
  });
  
  /// Tests if the point is inside the drawing
  bool hitTest(Offset point);
  
  /// Paints the drawing on the canvas
  void paint(Canvas canvas, Size size);
  
  /// Handles drag operations
  void onDrag(Offset delta);
}
```

## Next Steps

Now that you understand the data models used in the Deriv Chart library, you can explore:

- [Coordinate System](coordinate_system.md) - Learn how coordinates are managed
- [Rendering Pipeline](rendering_pipeline.md) - Understand how data is rendered
- [API Reference](../api_reference/series_classes.md) - Explore the complete API