---
title: Flutter Chart
description: A financial chart library for Flutter mobile apps
hide_table_of_contents: true
---

# Flutter Chart

A powerful and flexible financial charting library built specifically for Flutter applications. This package provides a comprehensive set of tools for creating interactive and customizable financial charts.

## Key Features

- 📊 **Multiple Chart Types**
  - Candlestick charts for detailed price movement analysis
  - Line charts for trend visualization
  - Area charts for volume or cumulative data

- 🎯 **Interactive Elements**
  - Horizontal barriers for price levels
  - Vertical markers for time indicators
  - Dynamic crosshair for precise value reading

- 🔍 **User Interaction**
  - Smooth zooming capabilities
  - Effortless scrolling through time periods
  - Responsive touch interactions

- 🛠 **Customization**
  - Custom indicators support
  - Flexible styling options
  - Configurable behaviors

## Quick Start

Add Flutter Chart to your project:

```yaml
deriv_chart:
  git:
    url: https://github.com/regentmarkets/flutter-chart.git
    ref: main
```

Create your first chart:

```Dart
import 'package:deriv_chart/deriv_chart.dart';

DerivChart(
        mainSeries: LineSeries([/* your list of ticks*/]),
        granularity: 1000,
        activeSybmol: 'default'
      )
```

## Ready to Start?

Check out our [Documentation](/docs/intro) to learn more about Flutter Chart's features and capabilities.
