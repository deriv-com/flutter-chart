# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Deriv Chart** is a financial charting library for Flutter that provides candlestick charts, line charts, technical indicators (RSI, MACD, Bollinger Bands, etc.), and interactive drawing tools. Built for trading platforms and financial applications.

- **Language**: Dart 3.0+
- **Framework**: Flutter 3.10.1+
- **Package Version**: 0.4.1

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run static analysis
flutter analyze --no-fatal-infos

# Check code formatting
dart format --set-exit-if-changed .

# Format code
dart format .

# Run all tests
flutter test

# Run code generation (for JSON serialization, etc.)
dart run build_runner build --delete-conflicting-outputs
```

### Example App
```bash
# Run example app from root
cd example && flutter run

# Build example APK
cd example && flutter build apk --target-platform android-arm,android-arm64,android-x64 --no-tree-shake-icons
```

## Architecture

### Widget Hierarchy

The chart uses a layered architecture with clear separation of concerns:

```
XAxisWrapper (platform-specific X-axis, data management, zoom/scroll)
  └── GestureManager (user interactions: pan, zoom, tap)
      └── Chart (visualization coordinator)
          ├── MainChart (primary chart: candles, overlays, crosshair, drawings)
          └── BottomCharts (indicators with separate Y-axis: RSI, MACD, etc.)
```

### Core Components

**XAxisWrapper**: Outermost layer handling platform-specific X-axis implementations (web/mobile), data management, zoom level (msPerPx), and scroll animations.

**GestureManager**: Manages all user interactions including pan, zoom, tap, and chart navigation.

**Chart**: Coordinates MainChart and multiple BottomCharts vertically. All charts share the same X-axis but have independent Y-axes.

**BasicChart**: Foundation class for all chart widgets. Manages Y-axis range (topBoundEpoch/bottomBoundEpoch), provides coordinate conversion functions (xFromEpoch, yFromQuote), handles grid lines and labels.

**MainChart**: Extends BasicChart. Displays main market data (LineSeries, CandleSeries), overlay indicators sharing Y-axis, drawing tools, crosshair, barriers, and markers.

**BottomChart**: Extends BasicChart. Shows indicators requiring independent Y-axis scaling (RSI, MACD), syncs with MainChart's X-axis viewport, supports dynamic add/remove.

### Data Model

**ChartData**: Abstract base for anything rendered on canvas (series, barriers, markers, annotations).

**Series**: Base class for chart series. Types with one data list extend **DataSeries** (LineSeries, CandleSeries, single indicators). Types with multiple data lists extend **Series** directly (AlligatorIndicator).

**DataSeries**: Superclass managing one sorted list of data by epoch. Includes binary search optimization for finding visible data points.

**ChartAnnotation**: Base for annotations without sequential data (barriers, tick indicators).

### Coordinate System

**X-Axis**: Based on `rightBoundEpoch` (timestamp at right edge) and `msPerPx` (milliseconds per pixel for zoom). Calculate `leftBoundEpoch = rightBoundEpoch - screenWidth * msPerPx`.

**Y-Axis**: Based on `topBoundEpoch` (max quote in visible area) and `bottomBoundEpoch` (min quote in visible area).

Coordinate conversion functions combine XAxisModel's `xFromEpoch` and chart's `yFromQuote` to plot any (epoch, quote) point on canvas.

### Painter Architecture

**SeriesPainter**: Abstract base responsible for painting series data.

**DataPainter**: Extends SeriesPainter for common DataSeries painting. Subclasses (LinePainter, CandlePainter, ScatterPainter) override `onPaintData` method.

Separation of concerns: Series classes handle calculation logic, SeriesPainter classes handle rendering operations.

### Interactive Layer (New)

Modern architecture for drawing tools with state pattern managing interaction modes:
- **Normal State**: Default, no tools selected
- **Selected Tool State**: A drawing tool is selected
- **Adding Tool State**: Creating new drawing tool

Each drawing tool has its own state (normal, selected, hovered, adding, dragging) affecting rendering and interactions. This will replace the previous drawing tools implementation.

### DerivChart Widget

Wrapper around Chart providing UI for adding/removing indicators and drawing tools with persistent storage. Use **DerivChart** instead of Chart when you need indicators and drawing tools functionality.

## Key Patterns

### Immutability
Prefer immutable objects for model classes. Benefits: predictability, consistency, performance optimization (especially for widget rebuilds), thread safety. Use `@immutable` annotation and const constructors where possible.

### Performance Optimizations
- Binary search for visible data (see `DataSeries` implementation)
- Caching indicator values on real-time updates (see `AbstractSingleIndicatorSeries`)
- Render only visible data points based on leftBoundEpoch/rightBoundEpoch range
- Use const constructors in widget trees

### Separation of Concerns
- Logic and painting are separate (Series classes vs SeriesPainter classes)
- Chart depends on abstractions (ChartData, Series) not concrete implementations
- Single Responsibility Principle throughout

### Code Generation
Uses `build_runner` for JSON serialization via `json_serializable`. Files with `.g.dart` extension are generated. After modifying models with JSON annotations, run: `dart run build_runner build --delete-conflicting-outputs`

## Project Structure

```
lib/src/
├── add_ons/                      # UI for indicators and drawing tools
│   ├── drawing_tools_ui/         # Drawing tool configuration UI
│   └── indicators_ui/            # Indicator configuration UI
├── deriv_chart/
│   ├── chart/
│   │   ├── data_visualization/
│   │   │   ├── annotations/      # Barriers, tick indicators
│   │   │   ├── chart_series/     # Series implementations
│   │   │   ├── drawing_tools/    # Drawing tool implementations
│   │   │   └── markers/          # Entry/exit markers
│   │   ├── helpers/              # Coordinate conversion, utilities
│   │   └── x_axis/               # X-axis platform implementations
│   └── theme/                    # Chart theming system
└── misc/                         # Shared utilities
```

## Theming

Chart has default dark/light themes switching based on `Theme.of(context).brightness`. To customize, extend `ChartDefaultDarkTheme` or `ChartDefaultLightTheme` and override specific properties. Pass custom theme to Chart widget.

Design tokens in `lib/src/theme/design_tokens/` define consistent styling values.

## Contributing Guidelines

**Code Style:**
- Follow Flutter/Dart best practices and conventions
- Use meaningful, descriptive names (avoid abbreviations)
- Line length: 80 characters max
- Use `PascalCase` for classes, `camelCase` for members/variables/functions, `snake_case` for files
- Functions should be short with single purpose (<20 lines preferred)

**Before Submitting:**
- Run `flutter analyze --no-fatal-infos` (must pass with no warnings)
- Run `flutter test` (all tests must pass)
- Run `dart format .` to format code
- Self-review changes
- Follow conventional commit format for PR titles (see conventionalcommits.org)

**Documentation:**
- Add dartdoc comments to all public APIs
- Provide examples for complex features
- Document non-obvious implementation decisions
- Update relevant markdown docs in `doc/` directory

**Architecture Considerations:**
- Maintain separation between logic and painting
- Depend on abstractions, not concrete implementations
- Consider performance impact (caching, visible data optimization)
- Keep Chart widget agnostic about what it renders
- Encapsulate functionality in small, composable components

## Additional Documentation

For detailed information, see:
- `doc/architecture.md` - Overall architecture patterns
- `doc/how_chart_lib_works.md` - Detailed technical explanation
- `doc/drawing_tools.md` - Drawing tools implementation
- `doc/interactive_layer.md` - New interactive layer architecture
- `doc/contribution.md` - Full contribution guidelines
