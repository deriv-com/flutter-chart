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

## Advanced Features

The Deriv Chart library provides several advanced features that can enhance your charts:

### Technical Indicators

| Parameter | Type | Description |
|-----------|------|-------------|
| `overlayConfigs` | `List<IndicatorConfig>` | Technical indicators to display on the main chart |
| `bottomConfigs` | `List<IndicatorConfig>` | Technical indicators to display in separate charts below the main chart |

### Annotations

| Parameter | Type | Description |
|-----------|------|-------------|
| `annotations` | `List<ChartAnnotation>` | Visual elements like horizontal/vertical barriers and tick indicators |

### Markers

| Parameter | Type | Description |
|-----------|------|-------------|
| `markerSeries` | `MarkerSeries` | Highlight specific points on the chart with interactive markers |

For detailed information and examples of these advanced features, see the [Advanced Features](advanced_features.md) documentation.

## DerivChart Widget

The `DerivChart` widget is a wrapper around the `Chart` widget that provides additional functionality for managing indicators and drawing tools:

| Parameter | Type | Description |
|-----------|------|-------------|
| `activeSymbol` | `String` | Symbol code for saving indicator settings |
| `indicatorsRepo` | `AddOnsRepository<IndicatorConfig>` | Repository for managing indicators |
| `drawingToolsRepo` | `AddOnsRepository<DrawingToolConfig>` | Repository for managing drawing tools |

For detailed information about using the DerivChart widget, see the [Advanced Features](advanced_features.md) documentation.

## Next Steps

Now that you understand the configuration options available in the Deriv Chart library, you can explore:

- [Advanced Features](advanced_features.md) - Learn about technical indicators, annotations, markers, and drawing tools
- [Custom Themes](../advanced_usage/custom_themes.md) - Learn about advanced customization options