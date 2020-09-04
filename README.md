[![Coverage Status](https://coveralls.io/repos/github/regentmarkets/flutter-chart/badge.svg?branch=pull/7&t=AA56dN)](https://coveralls.io/github/regentmarkets/flutter-chart?branch=pull/7)

# flutter-chart
Chart library for Flutter mobile apps

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
  // TODO: add granularity
  // TODO: add isLive
);
```

Chart will request more data on scrolling by calling `onLoadHistory` callback.
The callback being called means the chart wants `count` number of candles appended to the front of the `candles` list.

```dart
Chart(
  candles: candles,
  pipSize: 4,
  onLoadHistory: (int count) {
    // append [count] candles to the front of [data]
  },
);
```
