# Coordinate System

This document explains the coordinate system used in the Deriv Chart library, how it maps data points to screen coordinates, and how it handles scrolling and zooming.

## Overview

The Deriv Chart library uses a coordinate system that maps:
- Time (epochs) to X-coordinates on the screen
- Price (quotes) to Y-coordinates on the screen

This mapping is essential for:
- Rendering data points at the correct positions
- Handling user interactions (taps, drags)
- Implementing scrolling and zooming
- Supporting crosshair functionality

## X-Axis Coordinate System

The X-axis represents time and is managed by the `XAxisWrapper` component.

### Key Concepts

1. **rightBoundEpoch**: The timestamp at the right edge of the chart
2. **msPerPx**: Milliseconds per pixel (zoom level)
3. **leftBoundEpoch**: The timestamp at the left edge of the chart

### Calculations

The relationship between these values is:

```
leftBoundEpoch = rightBoundEpoch - screenWidth * msPerPx
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

### Zooming

Zooming is implemented by changing the `msPerPx`:
- Zooming in: Decrease `msPerPx` (fewer milliseconds per pixel)
- Zooming out: Increase `msPerPx` (more milliseconds per pixel)

```dart
void scale(double newMsPerPx) {
  // Calculate the center point of the visible area
  final centerEpoch = (rightBoundEpoch + leftBoundEpoch) ~/ 2;
  
  // Update msPerPx
  msPerPx = newMsPerPx;
  
  // Recalculate rightBoundEpoch to keep the center point fixed
  rightBoundEpoch = centerEpoch + (width * msPerPx / 2).toInt();
  
  notifyListeners();
}
```

## Y-Axis Coordinate System

The Y-axis represents price and is managed by each chart component (MainChart and BottomCharts) independently.

### Key Concepts

1. **topBoundQuote**: The maximum price in the visible area
2. **bottomBoundQuote**: The minimum price in the visible area
3. **topPadding** and **bottomPadding**: Padding to add above and below the data
4. **quotePerPx**: Price units per pixel

### Calculations

The relationship between these values is:

```
quotePerPx = (topBoundQuote - bottomBoundQuote) / (height - topPadding - bottomPadding)
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

## Grid System

The grid system uses the coordinate system to place grid lines and labels at appropriate intervals.

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

## Shared X-Axis, Independent Y-Axes

The Deriv Chart library uses a shared X-axis for all charts (MainChart and BottomCharts) but independent Y-axes:

1. The `XAxisWrapper` provides a single `XAxisModel` that is shared by all charts
2. Each chart (MainChart and BottomCharts) has its own Y-axis calculations

This allows:
- Synchronized scrolling and zooming across all charts
- Independent Y-axis scaling for each chart based on its data range

## Next Steps

Now that you understand the coordinate system used in the Deriv Chart library, you can explore:

- [Rendering Pipeline](rendering_pipeline.md) - Learn how data is rendered on the canvas
- [Architecture](architecture.md) - Understand the overall architecture of the library
- [API Reference](../api_reference/chart_widget.md) - Explore the complete API