# Deriv Chart

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/deriv-com/flutter-chart)

A financial charting library for Flutter applications, offering a comprehensive suite of features for technical analysis and trading visualization. It supports multiple chart types (candlestick, line, etc.), a wide range of technical indicators (RSI, MACD, Bollinger Bands, etc.), and interactive drawing tools. The library comes with customizable themes to match your application's visual style. Built specifically for financial applications, it includes essential features like price markers, barriers, and crosshairs, making it ideal for trading platforms, financial analysis tools, and market data visualization.


|<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/intro.gif" alt="intro" width="627" height="330">|
| ------------------ |


| Different Chart Types                                                                                                                                        | Annotations and Crosshair                                                                                                                                        |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/different_chart_types.gif" alt="Chart types" width="300" height="400"> | <img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/annotations_and_crosshair.gif" alt="Annotations" width="300" height="400"> |

| Technical Indicators                                                                                                                             | Interactive tools                                                                                                                                  |
|--------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/indicators.gif" alt="Indicators" width="300" height="400"> | <img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/interactive_tools.gif" alt="Tools" width="300" height="400"> |

## Requirements

- Dart SDK: >=3.0.0 <4.0.0
- Flutter: >=3.10.1

## Installation

Add this to your project's pubspec.yaml file:

```yaml
deriv_chart: ^0.3.7
```

## Usage

Import the library with:

```dart
import 'package:deriv_chart/deriv_chart.dart';
```

### Basic Chart

Simplest usage, adding a candlestick chart:

```dart
final candle1 = Candle(
  epoch: DateTime(...),
  high: 400,
  low: 50,
  open: 200,
  close: 100,
);
final candle2 = Candle(
  epoch: DateTime(...),
  high: 500,
  low: 100,
  open: 100,
  close: 500,
);

final candles = [candle1, candle2, ...]
// Or provide your own data from a data source.
...

Chart(
  mainSeries: CandleSeries(candles),
  pipSize: 3, // Number of decimal places when showing values on y-axis
  granularity: granularity, // Duration in milliseconds: for candles, this is the candle period; for ticks, this is the average time between ticks
);
```

<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/candle_chart_example.png" alt="candle_series" width="450" height="250"> 


Supply different `Series` for `mainSeries` parameter to switch between chart types (candle, line, etc.).
For example, to show a line chart we pass a `LineSeries`:

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 3,
);
```

<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/line_chart_example.png" alt="line_series" width="450" height="250"> 


### Styling Line/CandleSeries

You can change the appearance of Series by giving `style` to them.

```dart
Chart(
  mainSeries: CandleSeries(
    candles, 
    style: CandleStyle(
        positiveColor: Colors.green, 
        negativeColor: Colors.red
    ),
  ),
  ...
);
```

### Annotations

To add horizontal/vertical barriers, specify them in the `annotations` parameter of the chart:

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 3,
  annotations: <ChartAnnotation> [
    HorizontalBarrier(98161.950),
    VerticalBarrier(candles.last.epoch, title: 'V Barrier'),
  ],
);
```
<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/barriers_example.png" alt="h_and_v_barriers" width="450" height="250"> 

#### Styling Annotations

The appearance of `Annotations` can also be changed by passing custom styles.

```dart
HorizontalBarrier(
      ...
      style: HorizontalBarrierStyle(
        color: const Color(0xFF00A79E),
        isDashed: false,
      ),
      visibility: HorizontalBarrierVisibility.forceToStayOnRange,
    )
```

You can also create custom Barriers by creating subclasses of `ChartAnnotation` and draw the annotation differently.
(An example will be provided).


#### TickIndicator

For example, there is a special annotation called `TickIndicator` which is used to show a tick on the chart.

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 3,
  annotations: <ChartAnnotation> [
    TickIndicator(candles.last),
  ],
);
```

<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/tick_indicator_example.png" alt="sample_tick_indicator" width="450" height="250"> 

### Technical Indicators

Here's a comprehensive example showing how to use multiple indicators with different configurations:


#### Using overlayConfigs and bottomConfigs

You can add indicators by passing `overlayConfigs` and `bottomConfigs` to the `Chart` widget.
`overlayConfigs` are indicators that share the same y-axis as the main series and are drawn on top of it.
`bottomConfigs` are indicators that have a separate y-axis and are drawn below the main series.

```dart
Chart(
  mainSeries: CandleSeries(candles),
  overlayConfigs: [
    // Bollinger Bands
    BollingerBandsIndicatorConfig(
      period: 20,
      standardDeviation: 2,
      movingAverageType: MovingAverageType.exponential,
      upperLineStyle: LineStyle(color: Colors.purple),
      middleLineStyle: LineStyle(color: Colors.black),
      lowerLineStyle: LineStyle(color: Colors.blue),
    ),
  ],
  // Bottom indicators with separate scale
  bottomConfigs: [
    SMIIndicatorConfig(
      period: 14,
      signalPeriod: 9,
      lineStyle: LineStyle(color: Colors.blue, thickness: 2),
      signalLineStyle: LineStyle(color: Colors.red),
    ),
    // Relative Strength Index (RSI)
    RSIIndicatorConfig(
      period: 14,
      lineStyle: LineStyle(
        color: Colors.green,
        thickness: 1,
      ),
      oscillatorLinesConfig: OscillatorLinesConfig(
        overboughtValue: 70,
        oversoldValue: 30,
        overboughtStyle: LineStyle(color: Colors.red),
        oversoldStyle: LineStyle(color: Colors.green),
      ),
      showZones: true,
    ),
    SMIIndicatorConfig(period: 10, lineStyle: LineStyle(color: Colors.green))
  ],
  pipSize: 3,
  granularity: 60, // 1 minute candles
);
```
<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/bb_smi_rsi.png" alt="bb_and_smi_indicators" width="450" height="250"> 

## Available Indicators

The package includes the following technical indicators:

### Moving Averages

- Simple Moving Average (SMA)
- Exponential Moving Average (EMA)
- Double Exponential Moving Average (DEMA)
- Triple Exponential Moving Average (TEMA)
- Triangular Moving Average (TRIMA)
- Weighted Moving Average (WMA)
- Modified Moving Average (MMA)
- Least Squares Moving Average (LSMA)
- Hull Moving Average (HMA)
- Variable Moving Average (VMA)
- Welles Wilder Smoothing Moving Average (WWSMA)
- Zero-Lag Exponential Moving Average (ZELMA)

### Oscillators

- Relative Strength Index (RSI)
- Stochastic Momentum Index (SMI)
- Moving Average Convergence Divergence (MACD)
- Awesome Oscillator
- Williams %R
- Rate of Change (ROC)
- Chande Momentum Oscillator (CMO)
- Gator Oscillator

### Trend Indicators

- Average Directional Index (ADX)
- Parabolic SAR
- Ichimoku Cloud

### Volatility Indicators

- Bollinger Bands
- Average True Range (ATR)
- Standard Deviation
- Variance

### Channel Indicators

- Donchian Channel
- Moving Average Envelope

### Other Indicators

- Aroon
- Commodity Channel Index (CCI)
- Detrended Price Oscillator (DPO)
- ZigZag
- Fixed Channel Bands (FCB)
- Bullish/Bearish Pattern Recognition

### Drawing Tools

This section will be updated with comprehensive documentation about how to add and configure drawing tools.

For now, you can refer to the [Drawing Tools documentation](doc/drawing_tools.md) for more details.

### Callbacks

Use `onVisibleAreaChanged` for listening to chart's scrolling and zooming.
`leftEpoch` is the timestamp of the chart's left edge.
`rightEpoch` is the timestamp of the chart's right edge.
Check out the example where loading of more data on scrolling is implemented.

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
    // do something (e.g., load more data)
  },
);
```

Use `onCrosshairAppeared` for listening to the chart's crosshair.

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  onCrosshairAppeared: () => Vibration.vibrate(duration: 50),
);
```

### Markers

Supply `markerSeries` to show markers on the chart.

```dart
Chart(
  ...,
  markerSeries: MarkerSeries([
    Marker.up(epoch: 123, quote: 10, onTap: () {}),
    Marker.down(epoch: 124, quote: 12, onTap: () {}),
  ]),
);
```

Supply `activeMarker` to show an active marker on the chart.
See [example](example) for a complete implementation.

```dart
Chart(
  ...,
  markerSeries: MarkerSeries(
    [
      Marker.up(epoch: 123, quote: 10, onTap: () {}),
      Marker.down(epoch: 124, quote: 12, onTap: () {}),
    ],
    activeMarker: ActiveMarker(
      epoch: 123,
      quote: 10,
      onTap: () {},
      onOutsideTap: () {
        // remove active marker
      },
    ),
  ),
```

Supply `entryTick` and `exitTick` to show entry and exit tick markers.

```dart
Chart(
  ...,
  markerSeries: MarkerSeries(
    [...],
    entryTick: Tick(epoch: ..., quote: ...),
    exitTick: Tick(epoch: ..., quote: ...),
  ),
```


### Theme

The Chart has its own default dark and light themes that switch depending on `Theme.of(context).brightness` value.
You can supply your own theme, but then you would have to handle switching yourself. To do so, create your own theme class that either implements the `ChartTheme` interface or extends `ChartDefaultDarkTheme`/`ChartDefaultLightTheme`. Override only those properties that you need to be different and then pass it to the `Chart` widget. See [ChartTheme](lib/src/theme/chart_theme.dart) for more info.

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
}
```

```dart
Chart(
    ...
    theme: customTheme /*instance of your custom theme*/,
    ...
)
```

### Localization

To use ChartLocalization, add the `ChartLocalization.delegate` to your `localizationsDelegates` inside the `MaterialApp` where you added the chart.
When you want to change the locale of the chart, use this code:

```dart
ChartLocalization.load(locale);
```

### DerivChart

A wrapper around the `Chart` widget that provides functionality to add, remove, and update indicators, as well as manage saving and restoring selected ones in storage.
To learn more about how to customize the indicators feature using `DerivChart`, check [this documentation](doc/deriv_chart_widget_usage.md).

#### Usage:

All properties from the `Chart` widget are available here as well, except `overlaySeries` and `bottomSeries` which are managed internally.

```dart
DerivChart(
   mainSeries: CandleSeries(candles),
   granularity: 60, // 60 seconds
   activeSymbol: 'default',
   pipSize: 4,
)
```

### ChartController

A controller that can be provided to the chart to programmatically control scrolling and scaling behavior.

```dart
final ChartController _controller = ChartController();

....

Chart(
    ...
    controller: _controller,
    ...
)


_controller.scrollToLastTick();
_controller.scale(100);
```

## Additional Documentation

For more detailed information, check out these documentation files:

- [How Chart Library Works](doc/core_concepts/how_chart_lib_works.md)
- [Data Series](doc/data_series.png)
- [Data Painters](doc/data_painters.png)
- [Drawing Tools](doc/drawing_tools.md)
- [DerivChart Widget Usage](doc/deriv_chart_widget_usage.md)
- [Contributing](doc/contribution.md)

## Documentation Diagrams

The project uses Mermaid diagrams for visualizing architecture and processes. These diagrams are stored as separate files and referenced in the documentation.

### Updating Diagrams

1. Update diagrams and generate SVG files from the Mermaid code:
   - Update diagram code. You can use the [Mermaid Live Editor](https://mermaid.live/) or any other Mermaid-compatible editor.
   - Use the ![mermaid_script](scripts/convert_mmd_to_svg.sh) to generate SVG files 

2. The documentation files (like `doc/interactive_layer.md`) reference these SVG files using standard Markdown image syntax:
   ```markdown
   ![Diagram Title](diagrams/diagram_filename.svg)
   ```

This approach separates the diagram code from the documentation, making both easier to maintain.

## Dependencies

Key dependencies include:
- deriv_technical_analysis: ^1.1.1
- provider: ^6.0.5
- shared_preferences: ^2.1.0
- intl: ^0.19.0

For a complete list of dependencies, see the [pubspec.yaml](pubspec.yaml) file.
