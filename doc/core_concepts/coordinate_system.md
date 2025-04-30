# Coordinate System

This document explains the coordinate system used in the Deriv Chart library, how it maps data points to screen coordinates, and how it handles scrolling and zooming.

## Overview

The Deriv Chart library uses a coordinate system that maps:
- Time (epochs) to X-coordinates on the screen
- Price (quotes) to Y-coordinates on the screen

```
Y-axis (Price)
    ^
    |
    |                   • (epoch2, quote2)
    |
    |       • (epoch1, quote1)
    |
    |
    +---------------------------------> X-axis (Time)
```

This mapping is essential for:
- Rendering data points at the correct positions
- Handling user interactions (taps, drags)
- Implementing scrolling and zooming
- Supporting crosshair functionality
- Enabling drawing tools and annotations

## X-Axis Coordinate System

The X-axis represents time and is managed by the `XAxisWrapper` component, which serves as the foundation for horizontal positioning across the entire chart.

### Key Concepts

1. **rightBoundEpoch**: The timestamp at the right edge of the chart
2. **msPerPx**: Milliseconds per pixel (zoom level)
3. **leftBoundEpoch**: The timestamp at the left edge of the chart
4. **visibleTimeRange**: The time range currently visible on the chart

```
                leftBoundEpoch                      rightBoundEpoch
                      |                                   |
                      v                                   v
    +------------------+-----------------------------------+
    |                  |                                   |
    |  Past (not       |        Visible Area              |  Future (not 
    |  visible)        |                                  |  visible)
    |                  |                                  |
    +------------------+----------------------------------+
                       |<------- screenWidth (px) ------->|
                       |<------ visibleTimeRange -------->|
                       |      (screenWidth * msPerPx)     |
```

### Calculations

The relationship between these values is:

```
leftBoundEpoch = rightBoundEpoch - screenWidth * msPerPx
visibleTimeRange = screenWidth * msPerPx
```

Where:
- `screenWidth` is the width of the chart in pixels
- `msPerPx` determines how many milliseconds each pixel represents (zoom level)

### Coordinate Conversion

The `XAxisModel` provides functions to convert between epochs and X-coordinates:

- **xFromEpoch**: Converts a timestamp (epoch) to an X-coordinate on the screen
- **epochFromX**: Converts an X-coordinate on the screen to a timestamp (epoch)

These conversion functions are essential for mapping data points to screen positions and interpreting user interactions.

### Scrolling

Scrolling is implemented by changing the `rightBoundEpoch`:
- Scrolling right (into the past): Decrease `rightBoundEpoch`
- Scrolling left (into the future): Increase `rightBoundEpoch`

The `scrollBy` method adjusts the `rightBoundEpoch` based on the number of pixels scrolled, converting pixels to milliseconds using the current `msPerPx` value.

#### Edge Cases and Constraints

- **Live Data**: When displaying live data, the `rightBoundEpoch` may be constrained to the current time or the latest data point
- **Historical Limits**: The chart may impose limits on how far back in time users can scroll
- **Smooth Scrolling**: The chart implements momentum-based scrolling for a natural feel

### Zooming

Zooming is implemented by changing the `msPerPx`:
- Zooming in: Decrease `msPerPx` (fewer milliseconds per pixel)
- Zooming out: Increase `msPerPx` (more milliseconds per pixel)

The `scale` method updates the `msPerPx` value while maintaining the position of a focal point (typically the center of the chart or the point under the user's finger). This ensures that the chart zooms in or out around the expected point.

#### Zoom Constraints

The chart implements min and max zoom levels to ensure usability. The `msPerPx` value is constrained between minimum and maximum values to prevent users from zooming too far in or out.

## Y-Axis Coordinate System

The Y-axis represents price and is managed by each chart component (MainChart and BottomCharts) independently, allowing different scales for different types of data.

### Key Concepts

1. **topBoundQuote**: The maximum price in the visible area
2. **bottomBoundQuote**: The minimum price in the visible area
3. **topPadding** and **bottomPadding**: Padding to add above and below the data
4. **quotePerPx**: Price units per pixel
5. **visibleQuoteRange**: The price range currently visible on the chart

```
    ^
    |  topPadding
    +------------------+
    |                  |
    |  topBoundQuote   |
    |                  |
    |                  |
    |  Visible         |
    |  Quote Range     |
    |                  |
    |                  |
    |  bottomBoundQuote|
    |                  |
    +------------------+
    |  bottomPadding   |
    v
```

### Calculations

The relationship between these values is:

```
quotePerPx = (topBoundQuote - bottomBoundQuote) / (height - topPadding - bottomPadding)
visibleQuoteRange = topBoundQuote - bottomBoundQuote
```

Where:
- `height` is the height of the chart in pixels
- `topPadding` and `bottomPadding` are the padding values in pixels

### Coordinate Conversion

The `BasicChart` provides functions to convert between quotes and Y-coordinates:

- **yFromQuote**: Converts a price value (quote) to a Y-coordinate on the screen
- **quoteFromY**: Converts a Y-coordinate on the screen to a price value (quote)

These conversion functions are essential for mapping data points to screen positions and interpreting user interactions.

### Y-Axis Scaling

The Y-axis scale is determined by:
1. Finding the minimum and maximum values in the visible data
2. Adding padding to ensure data doesn't touch the edges
3. Adjusting for a consistent scale when animating

## Grid System

The grid system uses the coordinate system to place grid lines and labels at appropriate intervals, enhancing readability and providing visual reference points.

## Performance Considerations

### Clipping and Culling

For optimal performance, the chart only renders data points that are within the visible area:

The `isVisible` method checks if a data point is within the visible area of the chart. It compares the epoch and quote values against the current bounds to determine visibility.


## Coordinate System in Action

### Handling User Interactions

To convert a user tap to a data point:

The `onTap` method converts screen coordinates from a tap event to epoch and quote values using the coordinate conversion functions. This allows the chart to determine which data point the user tapped on.

### Drawing Tools and Annotations

Drawing tools and annotations use the coordinate system to position themselves on the chart:

The `drawHorizontalLine` and `drawVerticalLine` methods demonstrate how to draw horizontal and vertical lines at specific price levels or timestamps. These are used for barriers, support/resistance levels, and other annotations.

## Shared X-Axis, Independent Y-Axes

The Deriv Chart library uses a shared X-axis for all charts (MainChart and BottomCharts) but independent Y-axes:

```
+------------------------------------------+
|                                          |
|  MainChart (Y-axis for price data)       |
|                                          |
+------------------------------------------+
|                                          |
|  BottomChart 1 (Y-axis for RSI)          |
|                                          |
+------------------------------------------+
|                                          |
|  BottomChart 2 (Y-axis for MACD)         |
|                                          |
+------------------------------------------+
                   ^
                   |
             Shared X-axis
```

1. The `XAxisWrapper` provides a single `XAxisModel` that is shared by all charts
2. Each chart (MainChart and BottomCharts) has its own Y-axis calculations

This allows:
- Synchronized scrolling and zooming across all charts
- Independent Y-axis scaling for each chart based on its data range
- Consistent time alignment across all indicators

### Implementation Details

The `Chart` widget organizes the MainChart and BottomCharts in a vertical column. Each chart receives the same XAxisModel instance, ensuring that they share the same X-axis viewport. Each chart maintains its own Y-axis calculations based on its specific data.

## Real-World Applications

### Time-Series Analysis

The coordinate system enables sophisticated time-series analysis:

- **Trend Lines**: Drawing lines connecting significant points to identify trends
- **Support/Resistance Levels**: Horizontal lines at key price levels
- **Moving Averages**: Smoothed lines showing average prices over time
- **Fibonacci Retracements**: Horizontal lines at key Fibonacci levels

### Interactive Features

The coordinate system powers interactive features:

- **Crosshair**: Shows precise price and time at the cursor position
- **Tooltips**: Display data details at specific points
- **Selection**: Allows users to select specific time ranges for analysis
- **Zoom to Selection**: Enables users to zoom into a specific area of interest

## Integration with Other Components

The coordinate system integrates with other components of the Deriv Chart library:

- **Interactive Layer**: Uses the coordinate system to position drawing tools
- **Data Series**: Converts data points to screen coordinates for rendering
- **Indicators**: Calculate values based on data and render using the coordinate system
- **Annotations**: Position themselves on the chart using the coordinate system

## Next Steps

Now that you understand the coordinate system used in the Deriv Chart library, you can explore:

- [Rendering Pipeline](rendering_pipeline.md) - Learn how data is rendered on the canvas
- [Architecture](architecture.md) - Understand the overall architecture of the library
- [Data Models](data_models.md) - Explore the data models used in the library
- [Interactive Layer](../features/drawing_tools/overview.md) - Learn about the interactive drawing tools