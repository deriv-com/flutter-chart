# Deriv Chart Showcase App

A Flutter application showcasing the features and capabilities of the Deriv Chart package.

## Overview

This showcase app demonstrates various chart types and features available in the Deriv Chart package. It serves as both a visual demonstration and a reference implementation for developers using the package.

## Features

The app includes examples of:

### Basic Chart Types
- **Line Chart**: Basic line chart with customizable styles (thickness, color, area fill)
- **Candle Chart**: Japanese candlestick chart for price movement analysis
- **OHLC Chart**: Open-High-Low-Close chart for price data visualization
- **Hollow Candle Chart**: Hollow candlestick chart variation

### Chart Types with Indicators
- **Line Chart with Top Indicator**: Line chart with a Simple Moving Average indicator at the top
- **Candle Chart with Bottom Indicator**: Candle chart with RSI indicator at the bottom
- **OHLC Chart with Indicator**: OHLC chart with Bollinger Bands indicator
- **Hollow Candle Chart with Indicator**: Hollow candle chart with MACD indicator

### Advanced Features
- **Technical Indicators**: Charts with technical indicators like Bollinger Bands, RSI, and MACD
- **Barriers**: Charts with horizontal and vertical barriers and tick indicators
- **Markers**: Charts with up/down markers and active marker details
- **Drawing Tools**: Various drawing tools for technical analysis (Line, Horizontal, Vertical, Ray, Trend, Rectangle, Channel, Fibonacci Fan)
- **Theme Customization**: Customize chart appearance with different themes (light/dark and fully customizable colors)

## Usage

Each example screen demonstrates a specific feature of the Deriv Chart package with interactive controls to modify chart parameters and see the changes in real-time. The app includes:

- **Interactive Controls**: Sliders, switches, color pickers, and buttons to modify chart parameters
- **Real-time Updates**: See changes to the chart as you modify parameters
- **Sample Data Generation**: Automatically generated sample data for demonstration purposes

## Testing

This app can also be used for:

1. **Automation Testing**: The app is structured to facilitate automation testing of the chart components with semantic labels and consistent widget keys.
2. **Visual Testing**: Each chart example can be used for visual testing to verify that the visuals and painting of the charts are correct and meet expectations.
3. **Golden Testing**: The app provides a basis for golden testing to ensure visual consistency across different versions of the package.
4. **Interactive Testing**: The controls allow for manual testing of different chart configurations and edge cases.

## Getting Started

1. Ensure you have Flutter installed on your machine
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- Flutter SDK
- Deriv Chart package
