# Deriv Chart Documentation

<div align="center">
  <img src="images/deriv-chart.png" alt="Deriv Chart" width="400"/>
  <p><em>A powerful, customizable Flutter charting library for financial applications</em></p>
</div>

Welcome to the Deriv Chart documentation! This comprehensive guide will help you understand and use the Deriv Chart library effectively, whether you're a user of the library or a contributor to its development.

## Key Features

- **Multiple Chart Types**: Line, Candlestick, OHLC, and Hollow Candlestick charts
- **Technical Indicators**: Built-in support for popular indicators (Moving Averages, RSI, MACD, etc.)
- **Interactive Drawing Tools**: Trend lines, Fibonacci tools, and more for technical analysis
- **Real-time Updates**: Efficient handling of streaming data
- **Customizable Themes**: Fully customizable appearance to match your app's design
- **Responsive Design**: Works across different screen sizes and orientations
- **High Performance**: Optimized rendering for smooth scrolling and zooming

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Deriv Chart Example')),
        body: Center(
          child: SizedBox(
            height: 300,
            child: Chart(
              mainSeries: LineSeries([
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 5)), quote: 100),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 4)), quote: 120),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 3)), quote: 110),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 2)), quote: 130),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 1)), quote: 125),
                Tick(epoch: DateTime.now(), quote: 140),
              ]),
              pipSize: 2,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Table of Contents

- [Getting Started](#getting-started)
- [Core Concepts](#core-concepts)
- [Features](#features)
- [Advanced Usage](#advanced-usage)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Contributing](#contributing)
- [Support](#support)

## Getting Started

If you're new to the Deriv Chart library, start here to learn the basics:

- [Installation](getting_started/installation.md) - How to install and set up the library
- [Basic Usage](getting_started/basic_usage.md) - Create your first chart
- [Chart Types](getting_started/chart_types.md) - Learn about different chart types
- [Configuration](getting_started/configuration.md) - Understand configuration options

## Core Concepts

Understand the fundamental concepts behind the Deriv Chart library:

- [Architecture](core_concepts/architecture.md) - Overview of the library's architecture
- [Data Models](core_concepts/data_models.md) - Learn about the data structures
- [Coordinate System](core_concepts/coordinate_system.md) - How coordinates are managed
- [Rendering Pipeline](core_concepts/rendering_pipeline.md) - How data is rendered

## Features

Explore the features available in the Deriv Chart library:

### Chart Elements

- [Annotations](features/annotations.md) - Add horizontal and vertical barriers
- [Markers](features/markers.md) - Highlight specific points
- [Crosshair](features/crosshair.md) - Inspect data with precision

### Technical Analysis

- [Indicators](features/indicators/overview.md) - Add technical indicators
  - Moving Averages
  - Oscillators
  - Volatility Indicators
  - Trend Indicators

- [Drawing Tools](features/drawing_tools/overview.md) - Use interactive drawing tools
  - Lines and Channels
  - Fibonacci Tools
  - Geometric Shapes

### Interactive Layer

- [Interactive Layer](interactive_layer.md) - Understand the interactive layer architecture

## Advanced Usage

Take your charts to the next level with advanced techniques:

- [Custom Themes](advanced_usage/custom_themes.md) - Create custom chart themes
- [Performance Optimization](advanced_usage/performance_optimization.md) - Optimize chart performance
- [Real-time Data](advanced_usage/real_time_data.md) - Handle real-time data updates
- [Custom Indicators](advanced_usage/custom_indicators.md) - Create your own indicators
- [Custom Drawing Tools](advanced_usage/custom_drawing_tools.md) - Create your own drawing tools

## API Reference

Detailed API documentation for the Deriv Chart library:

- [Chart Widget](api_reference/chart_widget.md) - The main chart widget
- [Series Classes](api_reference/series_classes.md) - Data series classes
- [Indicator Classes](api_reference/indicator_classes.md) - Technical indicator classes
- [Drawing Tool Classes](api_reference/drawing_tool_classes.md) - Drawing tool classes
- [Theme Classes](api_reference/theme_classes.md) - Theme customization classes

## Examples

The library includes several examples to help you get started:

### Basic Examples

- [Line Chart](../example/lib/examples/basic/line_chart_example.dart)
- [Candlestick Chart](../example/lib/examples/basic/candle_chart_example.dart)
- [OHLC Chart](../example/lib/examples/basic/ohlc_chart_example.dart)
- [Hollow Candlestick Chart](../example/lib/examples/basic/hollow_candle_example.dart)

### Feature Examples

- [Chart with Indicators](../example/lib/examples/features/indicators_example.dart)
- [Chart with Drawing Tools](../example/lib/examples/features/drawing_tools_example.dart)
- [Chart with Annotations](../example/lib/examples/features/annotations_example.dart)
- [Chart with Markers](../example/lib/examples/features/markers_example.dart)

### Advanced Examples

- [Real-time Chart](../example/lib/examples/advanced/real_time_chart_example.dart)
- [Custom Theme](../example/lib/examples/advanced/custom_theme_example.dart)
- [Custom Indicator](../example/lib/examples/advanced/custom_indicator_example.dart)
- [Custom Drawing Tool](../example/lib/examples/advanced/custom_drawing_tool_example.dart)

You can find these examples in the `example` directory of the repository.

## Showcase App

The `showcase_app` directory contains a complete Flutter application that demonstrates all the features of the Deriv Chart library. You can use this app as a reference for your own implementation.

<div align="center">
  <img src="images/intro.gif" alt="Showcase App" width="300"/>
</div>

## Contributing

Learn how to contribute to the Deriv Chart library:

- [Contribution Guidelines](contribution.md) - How to contribute
- [Development Setup](development_setup.md) - Set up your development environment
- [Code Style](code_style.md) - Follow the code style guidelines
- [Testing](testing.md) - Write and run tests

## Compatibility

- **Flutter**: 3.10.1 or higher
- **Dart**: 3.0.0 or higher
- **Platforms**: iOS, Android, Web, macOS, Windows, Linux

## Support

If you need help with the Deriv Chart library, you can:

- Check the [FAQ](faq.md) for common questions
- Open an issue on [GitHub](https://github.com/your-organization/deriv-chart/issues)
- Contact the maintainers at support@example.com

## License

The Deriv Chart library is licensed under the [MIT License](../LICENSE).