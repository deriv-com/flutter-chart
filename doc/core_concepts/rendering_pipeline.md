# Rendering Pipeline

This document explains the rendering pipeline used in the Deriv Chart library, detailing how data flows from raw market data to visual elements on the screen.

## Overview

The rendering pipeline in the Deriv Chart library follows a clear 4-step process that is triggered whenever the viewport changes (through zooming or scrolling):

1. **Viewport Changes**: User interaction triggers zoom or scroll events
2. **Data Update**: Chart data objects update their visible data based on new viewport bounds
3. **Y-Axis Calculation**: Overall min/max values are calculated for proper scaling
4. **Painting**: Custom painters render all visual elements on the canvas

This pipeline ensures efficient rendering and a responsive user experience, even with large datasets.

## Rendering Process Steps

### Step 1: Viewport Changes
When users zoom or scroll the chart, the viewport boundaries change. This triggers the rendering pipeline by updating the left and right epoch boundaries that define what data should be visible.

### Step 2: Chart Data Update
Each chart data object's [`update(leftEpoch, rightEpoch)`](../api_reference/chart_data.md:25) method is called with the new viewport boundaries. During this update:
- Each chart data object calculates which data points fall within the visible range
- Min/max values are recalculated based on the visible data subset
- Data transformations (like indicator calculations) are applied if needed

### Step 3: Y-Axis Min/Max Calculation
The chart collects the min/max values from all chart data instances to determine the overall Y-axis scaling:
- Each chart data object provides its [`minValue`](../api_reference/chart_data.md:26) and [`maxValue`](../api_reference/chart_data.md:27)
- The chart calculates the overall minimum and maximum across all data objects
- Y-axis bounds are set with appropriate padding for optimal visualization

### Step 4: Custom Paint Rendering
The [`paint`](../api_reference/chart_data.md:30) method of the custom painter is called, which:
- Triggers each chart data object's [`paint`](../api_reference/chart_data.md:30) method
- Provides coordinate conversion functions ([`EpochToX`](../api_reference/coordinate_system.md:10), [`QuoteToY`](../api_reference/coordinate_system.md:15))
- Renders all visual elements in the correct layer order

## The ChartData Interface

At the core of the rendering pipeline is the `ChartData` interface, which defines the contract for all visual elements except for drawing tool that can be rendered on a chart:

```dart
abstract class ChartData {
  late String id;
  bool didUpdate(ChartData? oldData);
  bool shouldRepaint(ChartData? oldData);
  void update(int leftEpoch, int rightEpoch);
  double get minValue;
  double get maxValue;
  int? getMinEpoch();
  int? getMaxEpoch();
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
    ChartScaleModel chartScaleModel,
  );
}
```

All chart elements implement this interface, including:
- Chart types (LineSeries, CandleSeries, OHLCSeries, HollowCandleSeries)
- Technical indicators (both overlay and bottom indicators)
- Annotations (horizontal barriers, vertical barriers, tick indicators)
- Markers and other visual elements

The `ChartData` interface provides a unified way for the chart to:
1. Calculate visible data based on the current viewport
2. Determine min/max values for proper scaling
3. Paint elements on the canvas with appropriate coordinate transformations

## Data Processing

The data processing stage prepares raw market data for visualization by filtering visible data and calculating min/max values within the current viewport.

## Coordinate Mapping

The coordinate mapping stage converts data points to screen coordinates using transformation functions that map time values to X-coordinates and price values to Y-coordinates.

## Layer Composition

The chart uses multiple layers that are composited together:

1. **Grid Layer**: Background grid lines and labels
2. **Data Layer**: Main data series and overlay indicators
3. **Annotation Layer**: Barriers and other annotations
4. **Marker Layer**: Markers and active markers
5. **Crosshair Layer**: Crosshair lines and labels
6. **Interactive Layer**: Drawing tools and user interactions

## Optimization Techniques

The rendering pipeline includes several optimization techniques:

- **Binary Search**: Efficiently finds visible data range
- **Path Optimization**: Uses paths instead of individual line segments for better performance
- **Caching**: Indicator values are cached to avoid recalculation
- **Viewport Clipping**: Only elements within the viewport are rendered

## Painter Architecture

The library uses a decoupled painter architecture where:

- Each visual element type has specialized painters ([`LinePainter`](../api_reference/painters.md:10), [`CandlePainter`](../api_reference/painters.md:20), etc.)
- Painters can be reused across different chart data implementations
- Complex elements can compose multiple painters together

## Next Steps

Now that you understand the rendering pipeline used in the Deriv Chart library, you can explore:

- [Architecture](architecture.md) - Learn about the overall architecture of the library
- [Coordinate System](coordinate_system.md) - Understand how coordinates are managed
- [API Reference](../api_reference/chart_widget.md) - Explore the complete API