# Configuration Options

The Deriv Chart library provides numerous configuration options to customize the appearance and behavior of your charts. This guide explains the available options and how to use them.

## Chart Widget Configuration

The `Chart` widget accepts various parameters to customize its behavior and appearance:

### Basic Configuration

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  granularity: 60000, // 60000 milliseconds (1 minute)
  theme: ChartDefaultDarkTheme(),
  controller: ChartController(),
)
```

### Core Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mainSeries` | `Series` | The primary data series to display (required) |
| `pipSize` | `int` | Number of decimal places for price values (default: 2) |
| `granularity` | `int` | Time interval in milliseconds for candles or average ms difference between consecutive ticks (default: 60000) |
| `theme` | `ChartTheme` | Theme for the chart (default: based on app theme) |
| `controller` | `ChartController` | Controller for programmatic chart manipulation |

### Data Series Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `overlaySeries` | `List<Series>` | Additional series to display on the main chart |
| `bottomSeries` | `List<Series>` | Series to display in separate charts below the main chart |
| `markerSeries` | `MarkerSeries` | Markers to display on the chart |
| `overlayConfigs` | `List<IndicatorConfig>` | Technical indicators to display on the main chart |
| `bottomConfigs` | `List<IndicatorConfig>` | Technical indicators to display in separate charts below the main chart |

### Visual Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `annotations` | `List<ChartAnnotation>` | Annotations to display on the chart (barriers, etc.) |
| `showCrosshair` | `bool` | Whether to display crosshair on long press (default: true) |
| `showDataFitButton` | `bool` | Whether to display the data fit button (default: true) |
| `showScrollToLastTickButton` | `bool` | Whether to display scroll to last tick button (default: true) |
| `loadingAnimationColor` | `Color` | The color of the loading animation |
| `chartAxisConfig` | `ChartAxisConfig` | Configuration for chart axes including grid and labels |

### Callback Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onVisibleAreaChanged` | `Function(int leftEpoch, int rightEpoch)` | Called when the visible area changes due to scrolling or zooming |
| `onQuoteAreaChanged` | `Function(double minQuote, double maxQuote)` | Called when the visible quote area changes |
| `onCrosshairAppeared` | `VoidCallback` | Called when the crosshair appears |
| `onCrosshairDisappeared` | `VoidCallback` | Called when the crosshair disappears |
| `onCrosshairHover` | `OnCrosshairHoverCallback` | Called when the crosshair cursor is hovered/moved |

## PipSize

The `pipSize` parameter determines the number of decimal places displayed for price values on the Y-axis. For example:

- `pipSize: 2` displays prices as 123.45
- `pipSize: 3` displays prices as 123.456
- `pipSize: 0` displays prices as 123

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 3,
)
```

## Granularity

The `granularity` parameter specifies the time interval in milliseconds for candle charts. It affects how candles are grouped and displayed:

- `granularity: 60000` represents 1-minute candles
- `granularity: 300000` represents 5-minute candles
- `granularity: 3600000` represents 1-hour candles

```dart
Chart(
  mainSeries: CandleSeries(candles),
  pipSize: 2,
  granularity: 300000, // 5-minute candles (300000 milliseconds)
)
```

## Theme Customization

You can customize the appearance of the chart by providing a custom theme:

```dart
class CustomTheme extends ChartDefaultDarkTheme {
  @override
  GridStyle get gridStyle => GridStyle(
    gridLineColor: Colors.yellow,
    xLabelStyle: textStyle(
      textStyle: caption2,
      color: Colors.yellow,
      fontSize: 13,
    ),
  );
  
  @override
  CrosshairStyle get crosshairStyle => CrosshairStyle(
    lineColor: Colors.orange,
    labelBackgroundColor: Colors.orange.withOpacity(0.8),
    labelTextStyle: textStyle(
      textStyle: caption1,
      color: Colors.white,
    ),
  );
}

// Using the custom theme
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  theme: CustomTheme(),
)
```

## Chart Controller

The `ChartController` allows programmatic control of the chart:

```dart
final controller = ChartController();

// In your widget
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  controller: controller,
)

// Programmatically control the chart
controller.scrollToLastTick(); // Scroll to the most recent data
controller.scale(100); // Zoom the chart
controller.scroll(100); // Scroll by 100 pixels
```

### Available Controller Methods

| Method | Description |
|--------|-------------|
| `scrollToLastTick({bool animate = false})` | Scroll to the most recent data with optional animation |
| `scale(double scale)` | Set the zoom level |
| `scroll(double pxShift)` | Scroll by a specific number of pixels |

## Annotations

Annotations allow you to add visual elements to the chart, such as horizontal and vertical barriers:

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
        titleBackgroundColor: Colors.red.withOpacity(0.8),
        textStyle: TextStyle(color: Colors.white),
        labelShape: LabelShape.rectangle,
        labelHeight: 24,
        labelPadding: 4,
      ),
      visibility: HorizontalBarrierVisibility.forceToStayOnRange,
    ),
    VerticalBarrier(
      ticks[2].epoch,
      title: 'Event',
      style: VerticalBarrierStyle(
        color: Colors.blue,
        isDashed: false,
        titleBackgroundColor: Colors.blue.withOpacity(0.8),
        textStyle: TextStyle(color: Colors.white),
        labelPosition: VerticalBarrierLabelPosition.auto,
      ),
    ),
    TickIndicator(
      ticks.last,
      style: HorizontalBarrierStyle(
        labelShape: LabelShape.pentagon,
      ),
      visibility: HorizontalBarrierVisibility.normal,
    ),
  ],
)
```

## Markers

Markers allow you to highlight specific points on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries([
    Marker.up(epoch: ticks[1].epoch, quote: ticks[1].quote, onTap: () {
      print('Up marker tapped');
    }),
    Marker.down(epoch: ticks[3].epoch, quote: ticks[3].quote, onTap: () {
      print('Down marker tapped');
    }),
  ]),
)
```

### Active Marker

You can also display an active marker that responds to user interactions:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [
      Marker.up(epoch: ticks[1].epoch, quote: ticks[1].quote, onTap: () {}),
      Marker.down(epoch: ticks[3].epoch, quote: ticks[3].quote, onTap: () {}),
    ],
    activeMarker: ActiveMarker(
      epoch: ticks[1].epoch,
      quote: ticks[1].quote,
      onTap: () {
        print('Active marker tapped');
      },
      onOutsideTap: () {
        print('Tapped outside active marker');
        // Remove active marker
      },
    ),
  ),
)
```

## Entry and Exit Ticks

You can highlight entry and exit points on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [],
    entryTick: Tick(epoch: ticks[0].epoch, quote: ticks[0].quote),
    exitTick: Tick(epoch: ticks.last.epoch, quote: ticks.last.quote),
  ),
)
```

## DerivChart Configuration

The `DerivChart` widget is a wrapper around the `Chart` widget that provides additional functionality for managing indicators and drawing tools:

```dart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000, // 60000 milliseconds (1 minute)
  activeSymbol: 'R_100',
  pipSize: 4,
  // All Chart parameters are also available here
)
```

### DerivChart Specific Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `activeSymbol` | `String` | Symbol code for saving indicator settings |
| `indicatorsRepo` | `AddOnsRepository<IndicatorConfig>` | Repository for managing indicators |
| `drawingToolsRepo` | `AddOnsRepository<DrawingToolConfig>` | Repository for managing drawing tools |

## Next Steps

Now that you understand the configuration options available in the Deriv Chart library, you can explore:

- [Indicators](../features/indicators/overview.md) - Add technical indicators to your charts
- [Drawing Tools](../features/drawing_tools/overview.md) - Enable interactive drawing tools
- [Advanced Usage](../advanced_usage/custom_themes.md) - Learn about advanced customization options