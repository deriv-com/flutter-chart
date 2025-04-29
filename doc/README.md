# Deriv Chart Documentation

Welcome to the Deriv Chart documentation! This comprehensive guide will help you understand and use the Deriv Chart library effectively, whether you're a user of the library or a contributor to its development.

## Table of Contents

- [Getting Started](#getting-started)
- [Core Concepts](#core-concepts)
- [Features](#features)
- [Advanced Usage](#advanced-usage)
- [API Reference](#api-reference)
- [Contributing](#contributing)

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
  - [Moving Averages](features/indicators/moving_averages.md)
  - [Oscillators](features/indicators/oscillators.md)
  - [Volatility Indicators](features/indicators/volatility.md)
  - [Trend Indicators](features/indicators/trend_indicators.md)

- [Drawing Tools](features/drawing_tools/overview.md) - Use interactive drawing tools
  - [Lines and Channels](features/drawing_tools/lines_and_channels.md)
  - [Fibonacci Tools](features/drawing_tools/fibonacci_tools.md)
  - [Geometric Shapes](features/drawing_tools/geometric_shapes.md)

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

## Contributing

Learn how to contribute to the Deriv Chart library:

- [Contribution Guidelines](contribution.md) - How to contribute
- [Development Setup](development_setup.md) - Set up your development environment
- [Code Style](code_style.md) - Follow the code style guidelines
- [Testing](testing.md) - Write and run tests

## Examples

The library includes several examples to help you get started:

### Basic Examples

- Line Chart
- Candlestick Chart
- OHLC Chart
- Hollow Candlestick Chart

### Feature Examples

- Chart with Indicators
- Chart with Drawing Tools
- Chart with Annotations
- Chart with Markers

### Advanced Examples

- Real-time Chart
- Custom Theme
- Custom Indicator
- Custom Drawing Tool

You can find these examples in the `example` directory of the repository.

## Showcase App

The `showcase_app` directory contains a complete Flutter application that demonstrates all the features of the Deriv Chart library. You can use this app as a reference for your own implementation.

## Support

If you need help with the Deriv Chart library, you can:

- Check the [FAQ](faq.md) for common questions
- Open an issue on GitHub
- Contact the maintainers

## License

The Deriv Chart library is licensed under the [MIT License](../LICENSE).