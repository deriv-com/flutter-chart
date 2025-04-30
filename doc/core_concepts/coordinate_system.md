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

```dart
// Convert epoch to X-coordinate
double xFromEpoch(DateTime epoch) {
  return width - (rightBoundEpoch - epoch.millisecondsSinceEpoch) / msPerPx;
}

// Convert X-coordinate to epoch
DateTime epochFromX(double x) {
  return DateTime.fromMillisecondsSinceEpoch(
    rightBoundEpoch - ((width - x) * msPerPx).toInt(),
  );
}
```

### Scrolling

Scrolling is implemented by changing the `rightBoundEpoch`:
- Scrolling right (into the past): Decrease `rightBoundEpoch`
- Scrolling left (into the future): Increase `rightBoundEpoch`

```dart
void scrollBy(double pixels) {
  rightBoundEpoch -= (pixels * msPerPx).toInt();
  notifyListeners();
}
```

#### Edge Cases and Constraints

- **Live Data**: When displaying live data, the `rightBoundEpoch` may be constrained to the current time or the latest data point
- **Historical Limits**: The chart may impose limits on how far back in time users can scroll
- **Smooth Scrolling**: The chart implements momentum-based scrolling for a natural feel

### Zooming

Zooming is implemented by changing the `msPerPx`:
- Zooming in: Decrease `msPerPx` (fewer milliseconds per pixel)
- Zooming out: Increase `msPerPx` (more milliseconds per pixel)

```dart
void scale(double newMsPerPx, {double? focalPointX}) {
  // If no focal point is provided, use the center of the chart
  final double focusX = focalPointX ?? width / 2;
  
  // Calculate the epoch at the focal point
  final focalEpoch = epochFromX(focusX);
  
  // Update msPerPx
  msPerPx = newMsPerPx;
  
  // Recalculate rightBoundEpoch to keep the focal point at the same screen position
  rightBoundEpoch = focalEpoch.millisecondsSinceEpoch + ((width - focusX) * msPerPx).toInt();
  
  notifyListeners();
}
```

#### Zoom Constraints

The chart implements min and max zoom levels to ensure usability:

```dart
// Constrain msPerPx to reasonable limits
msPerPx = math.max(minMsPerPx, math.min(maxMsPerPx, msPerPx));
```

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

```dart
// Convert quote to Y-coordinate
double yFromQuote(double quote) {
  return height - bottomPadding - (quote - bottomBoundQuote) / quotePerPx;
}

// Convert Y-coordinate to quote
double quoteFromY(double y) {
  return bottomBoundQuote + (height - bottomPadding - y) * quotePerPx;
}
```

### Y-Axis Scaling

The Y-axis scale is determined by:
1. Finding the minimum and maximum values in the visible data
2. Adding padding to ensure data doesn't touch the edges
3. Adjusting for a consistent scale when animating

```dart
void updateYAxisBounds() {
  // Find min and max values in visible data
  double minValue = double.infinity;
  double maxValue = -double.infinity;
  
  for (final series in allSeries) {
    if (!series.minValue.isNaN && series.minValue < minValue) {
      minValue = series.minValue;
    }
    if (!series.maxValue.isNaN && series.maxValue > maxValue) {
      maxValue = series.maxValue;
    }
  }
  
  // Add padding
  final range = maxValue - minValue;
  final paddingAmount = range * 0.1; // 10% padding
  
  topBoundQuote = maxValue + paddingAmount;
  bottomBoundQuote = minValue - paddingAmount;
  
  // Update quotePerPx
  quotePerPx = (topBoundQuote - bottomBoundQuote) / (height - topPadding - bottomPadding);
}
```

#### Auto-Scaling and Fixed Scaling

The chart supports both auto-scaling and fixed scaling modes:

- **Auto-scaling**: The Y-axis automatically adjusts to fit the visible data
- **Fixed scaling**: The Y-axis maintains a fixed range regardless of the visible data

```dart
void setFixedYAxisBounds(double min, double max) {
  isFixedYAxis = true;
  bottomBoundQuote = min;
  topBoundQuote = max;
  updateQuotePerPx();
}

void resetToAutoYAxisBounds() {
  isFixedYAxis = false;
  updateYAxisBounds();
}
```

## Grid System

The grid system uses the coordinate system to place grid lines and labels at appropriate intervals, enhancing readability and providing visual reference points.

### X-Axis Grid

The X-axis grid is determined by:
1. Calculating the appropriate time interval based on the zoom level
2. Generating timestamps at regular intervals between `leftBoundEpoch` and `rightBoundEpoch`
3. Converting these timestamps to X-coordinates

```dart
List<DateTime> gridTimestamps() {
  final interval = timeGridInterval();
  final result = <DateTime>[];
  
  // Start from the leftmost visible timestamp aligned to the interval
  DateTime current = alignToInterval(
    DateTime.fromMillisecondsSinceEpoch(leftBoundEpoch),
    interval,
  );
  
  // Generate timestamps until we reach the right edge
  while (current.millisecondsSinceEpoch <= rightBoundEpoch) {
    result.add(current);
    current = addInterval(current, interval);
  }
  
  return result;
}
```

#### Dynamic Time Intervals

The chart dynamically selects appropriate time intervals based on the zoom level:

```dart
TimeInterval timeGridInterval() {
  // Calculate the minimum distance between grid lines in pixels
  const minDistanceBetweenLines = 60.0;
  
  // Calculate the time range that corresponds to the minimum distance
  final minTimeRange = minDistanceBetweenLines * msPerPx;
  
  // Select the appropriate interval
  if (minTimeRange < 60000) return TimeInterval.minute;
  if (minTimeRange < 3600000) return TimeInterval.hour;
  if (minTimeRange < 86400000) return TimeInterval.day;
  return TimeInterval.month;
}
```

### Y-Axis Grid

The Y-axis grid is determined by:
1. Calculating the appropriate price interval based on the visible range
2. Generating price values at regular intervals between `bottomBoundQuote` and `topBoundQuote`
3. Converting these price values to Y-coordinates

```dart
List<double> gridQuotes() {
  final interval = quoteGridInterval();
  final result = <double>[];
  
  // Start from the bottom aligned to the interval
  double current = (bottomBoundQuote / interval).floor() * interval;
  
  // Generate quotes until we reach the top
  while (current <= topBoundQuote) {
    result.add(current);
    current += interval;
  }
  
  return result;
}
```

#### Dynamic Price Intervals

The chart dynamically selects appropriate price intervals based on the visible range and chart height:

```dart
double quoteGridInterval() {
  // Calculate the minimum distance between grid lines in pixels
  const minDistanceBetweenLines = 40.0;
  
  // Calculate the quote range that corresponds to the minimum distance
  final minQuoteRange = minDistanceBetweenLines * quotePerPx;
  
  // Select the appropriate interval from predefined options
  final intervals = [0.00001, 0.0001, 0.001, 0.01, 0.1, 0.25, 0.5, 1, 2, 5, 10, 20, 25, 50, 100, 200, 500, 1000];
  
  for (final interval in intervals) {
    if (interval >= minQuoteRange) {
      return interval;
    }
  }
  
  return intervals.last;
}
```

## Performance Considerations

### Clipping and Culling

For optimal performance, the chart only renders data points that are within the visible area:

```dart
bool isVisible(DateTime epoch, double quote) {
  final epochMs = epoch.millisecondsSinceEpoch;
  return epochMs >= leftBoundEpoch &&
         epochMs <= rightBoundEpoch &&
         quote >= bottomBoundQuote &&
         quote <= topBoundQuote;
}
```

### Efficient Rendering

The chart uses efficient rendering techniques to handle large datasets:

1. **Data Decimation**: When zoomed out, the chart may reduce the number of points rendered
2. **Incremental Rendering**: For very large datasets, the chart may render incrementally
3. **Canvas Optimization**: The chart uses optimized Canvas drawing operations

```dart
void optimizedRenderDataPoints(List<DataPoint> points) {
  // Skip points that are too close together on screen
  double lastX = -double.infinity;
  const minXDistance = 1.0; // Minimum distance in pixels
  
  for (final point in points) {
    final x = xFromEpoch(point.epoch);
    
    if (x - lastX >= minXDistance) {
      final y = yFromQuote(point.quote);
      canvas.drawCircle(Offset(x, y), 2, paint);
      lastX = x;
    }
  }
}
```

## Coordinate System in Action

### Plotting Data Points

To plot a data point (epoch, quote) on the canvas:

```dart
void plotPoint(Canvas canvas, DateTime epoch, double quote) {
  final x = xFromEpoch(epoch);
  final y = yFromQuote(quote);
  
  canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.blue);
}
```

### Drawing Lines

To draw a line between two data points:

```dart
void drawLine(Canvas canvas, DateTime epoch1, double quote1, DateTime epoch2, double quote2) {
  final x1 = xFromEpoch(epoch1);
  final y1 = yFromQuote(quote1);
  final x2 = xFromEpoch(epoch2);
  final y2 = yFromQuote(quote2);
  
  canvas.drawLine(
    Offset(x1, y1),
    Offset(x2, y2),
    Paint()
      ..color = Colors.blue
      ..strokeWidth = 2,
  );
}
```

### Drawing Candles

To draw a candle:

```dart
void drawCandle(Canvas canvas, Candle candle) {
  final x = xFromEpoch(candle.epoch);
  final yOpen = yFromQuote(candle.open);
  final yHigh = yFromQuote(candle.high);
  final yLow = yFromQuote(candle.low);
  final yClose = yFromQuote(candle.close);
  
  // Draw wick
  canvas.drawLine(
    Offset(x, yHigh),
    Offset(x, yLow),
    Paint()
      ..color = Colors.black
      ..strokeWidth = 1,
  );
  
  // Draw body
  final bodyPaint = Paint()
    ..color = candle.isBullish ? Colors.green : Colors.red;
  
  canvas.drawRect(
    Rect.fromPoints(
      Offset(x - 4, yOpen),
      Offset(x + 4, yClose),
    ),
    bodyPaint,
  );
}
```

### Handling User Interactions

To convert a user tap to a data point:

```dart
void onTap(TapDownDetails details) {
  final x = details.localPosition.dx;
  final y = details.localPosition.dy;
  
  final epoch = epochFromX(x);
  final quote = quoteFromY(y);
  
  print('Tapped at epoch: $epoch, quote: $quote');
}
```

### Drawing Tools and Annotations

Drawing tools and annotations use the coordinate system to position themselves on the chart:

```dart
void drawHorizontalLine(Canvas canvas, double quote) {
  final y = yFromQuote(quote);
  
  canvas.drawLine(
    Offset(0, y),
    Offset(width, y),
    Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke,
  );
}

void drawVerticalLine(Canvas canvas, DateTime epoch) {
  final x = xFromEpoch(epoch);
  
  canvas.drawLine(
    Offset(x, 0),
    Offset(x, height),
    Paint()
      ..color = Colors.blue
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke,
  );
}
```

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

```dart
class Chart extends StatelessWidget {
  final XAxisModel xAxisModel;
  final MainChart mainChart;
  final List<BottomChart> bottomCharts;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main chart with its own Y-axis
        Expanded(
          flex: 3,
          child: mainChart.withXAxisModel(xAxisModel),
        ),
        
        // Bottom charts, each with its own Y-axis
        ...bottomCharts.map((chart) => 
          Expanded(
            flex: 1,
            child: chart.withXAxisModel(xAxisModel),
          ),
        ),
      ],
    );
  }
}
```

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