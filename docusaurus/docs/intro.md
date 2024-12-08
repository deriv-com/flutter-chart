---
sidebar_position: 1
---

[![Coverage Status](https://coveralls.io/repos/github/regentmarkets/flutter-chart/badge.svg?branch=pull/7&t=AA56dN)](https://coveralls.io/github/regentmarkets/flutter-chart?branch=pull/7)

# flutter-chart
A financial chart library for Flutter mobile apps.

## Getting Started

Add this to your project's pubspec.yaml file:

```yaml
deriv_chart:
  git:
    url: https://github.com/regentmarkets/flutter-chart.git
    ref: main # branch name
```

## Features

- Candlestick chart
- Line chart
- Area chart
- Barriers (horizontal lines)
- Markers (vertical lines)
- Zoom in/out
- Scroll
- Crosshair
- Custom indicators

## Usage

```dart
import 'package:deriv_chart/deriv_chart.dart';

// ...

ChartWidget(
  symbol: 'R_100', // The symbol to show its chart
  chartType: ChartType.candlestick,
  enableZoom: true,
  enableScroll: true,
  enableCrosshair: true,
  onCrosshairChange: (CrosshairState state) {
    // Handle crosshair state changes
  },
)
```

## Chart Types

### Candlestick Chart

A candlestick chart is a style of financial chart used to describe price movements of a security, derivative, or currency.

### Line Chart

A line chart is a type of chart which displays information as a series of data points called 'markers' connected by straight line segments.

### Area Chart

An area chart is a line chart with the area below the line filled with a color or gradient.

## Features Details

### Barriers

A `HorizontalBarrier` can have three different behaviors when it has a value that is not in the chart's Y-Axis value range.
  - `normal`: Won't force the chart to keep the barrier in its Y-Axis range, if the barrier was out of range it will go off the screen.
  - `keepBarrierLabelVisible`: Won't force the chart to keep the barrier in its Y-Axis range, if it was out of range, will show it on top/bottom edge with an arrow which indicates its value is beyond the Y-Axis range.
  - `forceToStayOnRange`: Will force the chart to keep this barrier in its Y-Axis range by widening its range to cover its value.

### Markers

A `VerticalMarker` is a vertical line that can be added to the chart to mark a specific time.

### Zoom

The chart can be zoomed in/out using pinch gestures or buttons.

### Scroll

The chart can be scrolled horizontally to view different time periods.

### Crosshair

A crosshair can be enabled to show the exact values at a specific point on the chart.

### Custom Indicators

You can add custom indicators to the chart by implementing the `Indicator` interface.
