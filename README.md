[![Coverage Status](https://coveralls.io/repos/github/regentmarkets/flutter-chart/badge.svg?branch=pull/7&t=AA56dN)](https://coveralls.io/github/regentmarkets/flutter-chart?branch=pull/7)

# flutter-chart
A financial chart library for Flutter mobile apps.

## Getting Started

Add this to your project's pubspec.yaml file:

```yaml
deriv_chart:
    git:
      url: git@github.com:regentmarkets/flutter-chart.git
      ref: dev
```

## Usage

Import the library with:

```dart
import 'package:deriv_chart/deriv_chart.dart';
```

Simplest usage:

```dart
final candle1 = Candle(
  epoch: DateTime.now().millisecondsSinceEpoch - 1000,
  high: 400,
  low: 50,
  open: 200,
  close: 100,
);
final candle2 = Candle(
  epoch: DateTime.now().millisecondsSinceEpoch,
  high: 500,
  low: 100,
  open: 100,
  close: 500,
);

Chart(
  mainSeries: CandleSeries([candle1, candle2]),
  pipSize: 4, // digits after decimal point
  granularity: granularity, // duration of 1 candle in ms (for ticks: average ms difference between ticks)
  // TODO: add isLive
);
```

Supply different `Series` for `mainSeries` parameter to switch between chart types (candle / line).

```dart
Chart(
  mainSeries: LineSeries([candle1, candle2]),
  pipSize: 4,
);
```

#### Styling Line/CandleSeries

You can change the appearance of Line/CandleSeries by giving `style`to them.

```dart
Chart(
  mainSeries: CandleSeries(
    [candle1, candle2], 
    style: CandleStyle(
        positiveColor: Colors.green, 
        negativColor: Colors.red
    ),
  ),
  ...
);
```

### Indicators

To add more series, like indicators with the same y-scale supply them as an array to the `overlaySeries` parameter.

```dart
Chart(
  mainSeries: LineSeries([candle1, candle2]),
  overlaySeries: [
    MASeries(IndicatorInput(candles, granularity)),
  ],
  pipSize: 4,
);
```

Bottom indicators which have a different Y-scale than the main chart can be passed as the `bottomSeries` parameter to the Chart.

```dart
Chart(
  mainSeries: LineSeries([candle1, candle2]),
  bottomSeries: [
    RSISeries(IndicatorInput(candles, granularity)),
  ],
  pipSize: 4,
);
```

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

### Barriers

To add horizontal/vertical barriers, specify them in the `annotations` parameter of the chart.

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  annotations: <ChartAnnotation> [
    HorizontalBarrier(60, title: 'Take profit'),
    VerticalBarrier(candles.last.epoch, title: 'Buy time'),
  ],
);
```

#### Styling

The appearance of `Barriers` can also be changed by passing custom styles.

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

A `HorizontalBarrier` can have three different behaviors when it has a value that is not in the chart's Y-Axis value range.
  - `normal`: Won't force the chart to keep the barrier in its Y-Axis range, if the barrier was out of range it will go off the screen.
  - `keepBarrierLabelVisible`: Won't force the chart to keep the barrier in its Y-Axis range, if it was out of range, will show it on top/bottom edge with an arrow which indicates its value is beyond the Y-Axis range.
  - `forceToStayOnRange`: Will force the chart to keep this barrier in its Y-Axis range by widening its range to cover its value.

### Theme

Chart has its own default dark and light themes that switch depending on `Theme.of(context).brightness` value.
You can supply your theme, but then you would have to handle switching yourself. To do so create you own theme class which either implements `ChartTheme` or extends `ChartDefaultDarkTheme`/`ChartDefaultLightTheme` and override only those properties that you need to be different and then pass it to the `Chart` widget. See [ChartTheme](https://github.com/regentmarkets/flutter-chart/blob/dev/lib/src/theme/chart_theme.dart) for more info.

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
When you want to change the locale of the chart,use this code:

```dart
ChartLocalization.load(locale);
```

### DerivChart

A wrapper around the `chart` widget which provides the UI to add/remove indicators and to manage saving/restoring selected ones on storage.

#### Usage:

All of the properties from the `Chart` widget are available here as well, except `overlaySeries`, `bottomSeries` that are managed internally.

```Dart
DerivChart(
   mainSeries: ...,
   annotations .
   ...
)
```

## ChartController

Can be provided and passed to the chart to control some behaviors of the chart.
For now, there is only one method `scrollToLastTick` whichs makes the chart's scroll position to point to the most recent data.

```dart
final ChartController _controller = ChartController();

....

Chart(
    controller: _controller
)
```

and whenever you want to do that, `_controller.scrollToLastTick()` can be called.
