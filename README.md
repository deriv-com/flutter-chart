# flutter-chart

A financial chart library for Flutter mobile apps.

## Requirements

- Dart SDK: >=3.0.0 <4.0.0
- Flutter: >=3.10.1

## Installation

Add this to your project's pubspec.yaml file:

```yaml
deriv_chart: ^0.3.4
```

## Usage

Import the library with:

```dart
import 'package:deriv_chart/deriv_chart.dart';
```

### Basic Chart

Simplest usage:

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
  pipSize: 4, // Number of decimal places when showing values on y-axis
  granularity: granularity, // duration of 1 candle in ms (for ticks: average ms difference between ticks)
);
```

<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/simple_candle_series.png" alt="candle_series" width="200" height="300"> 


Supply different `Series` for `mainSeries` parameter to switch between chart types (candle / line).

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
);
```

<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/simple_line_series.png" alt="line_series" width="200" height="300"> 


### Styling Line/CandleSeries

You can change the appearance of Line/CandleSeries by giving `style` to them.

```dart
Chart(
  mainSeries: CandleSeries(
    candles, 
    style: CandleStyle(
        positiveColor: Colors.green, 
        negativColor: Colors.red
    ),
  ),
  ...
);
```

### Annotations

To add horizontal/vertical barriers, specify them in the `annotations` parameter of the chart.

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  annotations: <ChartAnnotation> [
    HorizontalBarrier(866.416),
    VerticalBarrier(candles[100].epoch, title: 'V Barrier'),
  ],
);
```
<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/h_and_v_barriers.png" alt="h_and_v_barriers" width="200" height="300"> 

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

#### Horizontal Barrier's Visibility

A `HorizontalBarrier` can have three different behaviors when it has a value that is not in the chart's Y-Axis value range:
- `normal`: Won't force the chart to keep the barrier in its Y-Axis range, if the barrier was out of range it will go off the screen.
- `keepBarrierLabelVisible`: Won't force the chart to keep the barrier in its Y-Axis range, if it was out of range, will show it on top/bottom edge with an arrow which indicates its value is beyond the Y-Axis range.
- `forceToStayOnRange`: Will force the chart to keep this barrier in its Y-Axis range by widening its range to cover its value.

#### TickIndicator

For example there is a special annotation called `TickIndicator` which is used to show a tick on the chart.

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  annotations: <ChartAnnotation> [
    TickIndicator(candles.last),
  ],
);
```

<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/sample_tick_indicator.png" alt="sample_tick_indicator" width="200" height="300"> 

### Technical Indicators

Here's a comprehensive example showing how to use multiple indicators with different configurations:


#### Using overlayConfigs and bottomConfigs

You can add indicators by passing `overlayConfigs` and `bottomConfigs` to the `Chart` widget.
`overlayConfigs` are indicators that share the same y-axis as the main series and are drawn on top of it.
`bottomConfigs` are indicators that have a separate y-axis and are drawn below the main series.:

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
  ],
  pipSize: 4,
  granularity: 60, // 1 minute candles
);
```
<img src="https://raw.githubusercontent.com/deriv-com/flutter-chart/master/doc/images/bb_and_smi_indicators.png" alt="bb_and_smi_indicators" width="200" height="300"> 

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

For now, you can refer to the [Drawing Tools documentation](/doc/drawing_tools.md) for more details.

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
    // do something (e.g. load more data)
  },
);
```

Use `onCrosshairAppeared` for listening to chart's cross-hair.

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

Supply `activeMarker` to show active marker on the chart.
See `/example` for a complete implementation.

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

Chart has its own default dark and light themes that switch depending on `Theme.of(context).brightness` value.
You can supply your theme, but then you would have to handle switching yourself. To do so create you own theme class which either implements `ChartTheme` or extends `ChartDefaultDarkTheme`/`ChartDefaultLightTheme` and override only those properties that you need to be different and then pass it to the `Chart` widget. See [ChartTheme](https://github.com/deriv-com/flutter-chart/blob/dev/lib/src/theme/chart_theme.dart) for more info.

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

To use the ChartLocalization, you should add the `ChartLocalization.delegate` to your `localizationsDelegates` inside the `MaterialApp` that you added the chart in.
When you want to change the locale of the chart, use this code:

```dart
ChartLocalization.load(locale);
```

### DerivChart

A wrapper around the `chart` widget provides the functionality to add/remove/update indicators and to manage saving/restoring selected ones on storage.
To learn more about how we can customize the indicators feature using `DerivChart` check [this documentation](/doc/deriv_chart_widget_usage.md).

#### Usage:

All of the properties from the `Chart` widget are available here as well, except `overlaySeries`, `bottomSeries` that are managed internally.

```dart
DerivChart(
   mainSeries: CandleSeries(candles),
   granularity: 60, // 60 seconds
   activeSymbol: 'default',
   pipSize: 4,
)
```

### ChartController

Can be provided and passed to the chart to control some behaviors of the chart.
For now, there is only one method `scrollToLastTick` which makes the chart's scroll position point to the most recent data.

```dart
final ChartController _controller = ChartController();

....

Chart(
    ...
    controller: _controller,
    ...
)
```

and whenever you want to do that, `_controller.scrollToLastTick()` can be called.

## Additional Documentation

For more detailed information, check out these documentation files:

- [How Chart Library Works](/doc/how_chart_lib_works.md)
- [Data Series](/doc/data_series.png)
- [Data Painters](/doc/data_painters.png)
- [Drawing Tools](/doc/drawing_tools.md)
- [DerivChart Widget Usage](/doc/deriv_chart_widget_usage.md)
- [Contributing](/doc/contribution.md)

## Dependencies

Key dependencies include:
- deriv_technical_analysis: ^1.1.1
- provider: ^6.0.5
- shared_preferences: ^2.1.0
- intl: ^0.19.0

For a complete list of dependencies, see the [pubspec.yaml](pubspec.yaml) file.
