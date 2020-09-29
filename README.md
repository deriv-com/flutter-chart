[![Coverage Status](https://coveralls.io/repos/github/regentmarkets/flutter-chart/badge.svg?branch=pull/7&t=AA56dN)](https://coveralls.io/github/regentmarkets/flutter-chart?branch=pull/7)

# flutter-chart
A financial chart library for Flutter mobile apps

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
  candles: [candle1, candle2],
  pipSize: 4, // digits after decimal point
  style: ChartStyle.candles,
  granularity: granularity, // duration of 1 candle in ms (for ticks: average ms difference between ticks)
  // TODO: add isLive
);
```

Supply different `ChartStyle` to switch between chart types (candle / line).

```dart
Chart(
  candles: [candle1, candle2],
  pipSize: 4,
  style: ChartStyle.line,
);
```

Use `onVisibleAreaChanged` for listening to chart's scrolling and zooming.
`leftEpoch` is the timestamp of the chart's left edge.
`rightEpoch` is the timestamp of the chart's right edge.
Check out the example where loading of more data on scrolling is implemented.

```dart
Chart(
  candles: candles,
  pipSize: 4,
  onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
    // do something (e.g. load more data)
  },
);
```

Use `onCrosshairAppeared` for listening to chart's crosshair.

```dart
Chart(
  candles: candles,
  pipSize: 4,
  onCrosshairAppeared: () => Vibration.vibrate(duration: 50),
);
```

Chart has its own default dark and light themes that switch depending on `Theme.of(context).brightness` value.
You can supply your own theme, but then you would have to handle switching yourself. See [ChartTheme](https://github.com/regentmarkets/flutter-chart/blob/dev/lib/src/theme/chart_theme.dart) for more info.
