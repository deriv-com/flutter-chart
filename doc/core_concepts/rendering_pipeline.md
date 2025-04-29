# Rendering Pipeline

This document explains the rendering pipeline used in the Deriv Chart library, detailing how data flows from raw market data to visual elements on the screen.

## Overview

The rendering pipeline in the Deriv Chart library consists of several stages:

1. **Data Processing**: Preparing and filtering data for visualization
2. **Coordinate Mapping**: Converting data points to screen coordinates
3. **Painting**: Drawing the visual elements on the canvas
4. **Composition**: Combining multiple layers into the final chart

This pipeline ensures efficient rendering and a responsive user experience, even with large datasets.

## Data Processing Stage

The data processing stage prepares the raw market data for visualization:

### Data Sorting

All data is sorted chronologically by epoch (timestamp):

```dart
void sortData() {
  data.sort((a, b) => a.epoch.compareTo(b.epoch));
}
```

### Visible Data Calculation

Only data within the visible range is processed for rendering:

```dart
void updateVisibleRange(int leftEpoch, int rightEpoch) {
  visibleData = _getVisibleData(leftEpoch, rightEpoch);
  _calculateMinMaxValues();
}

List<T> _getVisibleData(int leftEpoch, int rightEpoch) {
  // Use binary search to find the start and end indices
  final startIndex = _binarySearchStartIndex(leftEpoch);
  final endIndex = _binarySearchEndIndex(rightEpoch);
  
  // Return the slice of data within the visible range
  return data.sublist(startIndex, endIndex + 1);
}
```

### Min/Max Value Calculation

The minimum and maximum values in the visible range are calculated:

```dart
void _calculateMinMaxValues() {
  if (visibleData.isEmpty) {
    _minValue = double.nan;
    _maxValue = double.nan;
    return;
  }
  
  _minValue = double.infinity;
  _maxValue = -double.infinity;
  
  for (final item in visibleData) {
    final value = _getValue(item);
    if (value < _minValue) _minValue = value;
    if (value > _maxValue) _maxValue = value;
  }
}
```

### Data Transformation

Some series types (like indicators) transform the raw data:

```dart
List<Tick> _calculateIndicatorValues() {
  final result = <Tick>[];
  
  // Apply the indicator calculation to the data
  for (int i = period - 1; i < data.length; i++) {
    final value = _calculateIndicatorValue(i);
    result.add(Tick(
      epoch: data[i].epoch,
      quote: value,
    ));
  }
  
  return result;
}
```

## Coordinate Mapping Stage

The coordinate mapping stage converts data points to screen coordinates:

### X-Coordinate Mapping

Time values (epochs) are mapped to X-coordinates:

```dart
double xFromEpoch(DateTime epoch) {
  return width - (rightBoundEpoch - epoch.millisecondsSinceEpoch) / msPerPx;
}
```

### Y-Coordinate Mapping

Price values (quotes) are mapped to Y-coordinates:

```dart
double yFromQuote(double quote) {
  return height - bottomPadding - (quote - bottomBoundQuote) / quotePerPx;
}
```

### Viewport Clipping

Data points outside the viewport are clipped:

```dart
bool isInViewport(double x, double y) {
  return x >= 0 && x <= width && y >= 0 && y <= height;
}
```

## Painting Stage

The painting stage draws the visual elements on the canvas:

### SeriesPainter

The `SeriesPainter` is the base class for all painters:

```dart
abstract class SeriesPainter {
  final Series series;
  
  SeriesPainter(this.series);
  
  void onPaint(
    Canvas canvas,
    Size size,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  );
}
```

### DataPainter

The `DataPainter` extends `SeriesPainter` to handle sequential data:

```dart
abstract class DataPainter<T> extends SeriesPainter {
  final DataSeries<T> dataSeries;
  
  DataPainter(this.dataSeries) : super(dataSeries);
  
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  ) {
    // Common setup for all data painters
    
    // Call the specific painting implementation
    onPaintData(
      canvas,
      size,
      dataSeries.visibleData,
      xFromEpoch,
      yFromQuote,
    );
  }
  
  void onPaintData(
    Canvas canvas,
    Size size,
    List<T> data,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  );
}
```

### Specific Painters

Each chart type has its own painter implementation:

#### LinePainter

```dart
class LinePainter extends DataPainter<Tick> {
  final LineSeries lineSeries;
  
  LinePainter(this.lineSeries) : super(lineSeries);
  
  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    List<Tick> data,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  ) {
    if (data.isEmpty) return;
    
    final path = Path();
    final paint = Paint()
      ..color = lineSeries.style.color
      ..strokeWidth = lineSeries.style.thickness
      ..style = PaintingStyle.stroke;
    
    // Move to the first point
    final firstX = xFromEpoch(data.first.epoch);
    final firstY = yFromQuote(data.first.quote);
    path.moveTo(firstX, firstY);
    
    // Add line segments to each subsequent point
    for (int i = 1; i < data.length; i++) {
      final x = xFromEpoch(data[i].epoch);
      final y = yFromQuote(data[i].quote);
      path.lineTo(x, y);
    }
    
    // Draw the path
    canvas.drawPath(path, paint);
  }
}
```

#### CandlePainter

```dart
class CandlePainter extends DataPainter<Candle> {
  final CandleSeries candleSeries;
  
  CandlePainter(this.candleSeries) : super(candleSeries);
  
  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    List<Candle> data,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  ) {
    if (data.isEmpty) return;
    
    final style = candleSeries.style;
    final wickPaint = Paint()
      ..strokeWidth = style.wickWidth;
    final bodyPaint = Paint();
    
    for (final candle in data) {
      final x = xFromEpoch(candle.epoch);
      final yOpen = yFromQuote(candle.open);
      final yHigh = yFromQuote(candle.high);
      final yLow = yFromQuote(candle.low);
      final yClose = yFromQuote(candle.close);
      
      // Determine colors based on candle direction
      final isPositive = candle.close >= candle.open;
      wickPaint.color = isPositive ? style.positiveColor : style.negativeColor;
      bodyPaint.color = isPositive ? style.positiveColor : style.negativeColor;
      
      // Draw wick
      canvas.drawLine(
        Offset(x, yHigh),
        Offset(x, yLow),
        wickPaint,
      );
      
      // Draw body
      final halfBodyWidth = style.bodyWidth / 2;
      canvas.drawRect(
        Rect.fromPoints(
          Offset(x - halfBodyWidth, yOpen),
          Offset(x + halfBodyWidth, yClose),
        ),
        bodyPaint,
      );
    }
  }
}
```

### Barrier Painters

Barriers have their own painters:

```dart
class HorizontalBarrierPainter extends SeriesPainter {
  final HorizontalBarrier barrier;
  
  HorizontalBarrierPainter(this.barrier) : super(barrier);
  
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  ) {
    final y = yFromQuote(barrier.value);
    
    // Draw the horizontal line
    final paint = Paint()
      ..color = barrier.style.color
      ..strokeWidth = barrier.style.lineThickness;
    
    if (barrier.style.isDashed) {
      // Draw dashed line
      drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    } else {
      // Draw solid line
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw the label if provided
    if (barrier.title != null) {
      drawLabel(
        canvas,
        barrier.title!,
        Offset(10, y),
        barrier.style.labelBackgroundColor,
        barrier.style.labelTextStyle,
      );
    }
  }
}
```

## Composition Stage

The composition stage combines multiple layers into the final chart:

### Layer Management

The chart manages multiple layers:

1. **Grid Layer**: Background grid lines and labels
2. **Data Layer**: Main data series and overlay indicators
3. **Annotation Layer**: Barriers and other annotations
4. **Marker Layer**: Markers and active markers
5. **Crosshair Layer**: Crosshair lines and labels
6. **Interactive Layer**: Drawing tools and user interactions

### Layer Ordering

Layers are painted in a specific order to ensure proper visual hierarchy:

```dart
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Grid layer (bottom)
      GridLayer(
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
        theme: theme,
      ),
      
      // Data layer
      DataLayer(
        mainSeries: mainSeries,
        overlaySeries: overlaySeries,
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
      ),
      
      // Annotation layer
      AnnotationLayer(
        annotations: annotations,
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
      ),
      
      // Marker layer
      MarkerLayer(
        markerSeries: markerSeries,
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
      ),
      
      // Interactive layer
      InteractiveLayer(
        drawingTools: drawingTools,
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
      ),
      
      // Crosshair layer (top)
      CrosshairLayer(
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
        theme: theme,
      ),
    ],
  );
}
```

### CustomPaint

Each layer uses `CustomPaint` to render its content:

```dart
class DataLayer extends StatelessWidget {
  final Series mainSeries;
  final List<Series> overlaySeries;
  final XAxisModel xAxisModel;
  final YAxisModel yAxisModel;
  
  const DataLayer({
    required this.mainSeries,
    required this.overlaySeries,
    required this.xAxisModel,
    required this.yAxisModel,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DataLayerPainter(
        mainSeries: mainSeries,
        overlaySeries: overlaySeries,
        xAxisModel: xAxisModel,
        yAxisModel: yAxisModel,
      ),
      size: Size.infinite,
    );
  }
}

class DataLayerPainter extends CustomPainter {
  final Series mainSeries;
  final List<Series> overlaySeries;
  final XAxisModel xAxisModel;
  final YAxisModel yAxisModel;
  
  DataLayerPainter({
    required this.mainSeries,
    required this.overlaySeries,
    required this.xAxisModel,
    required this.yAxisModel,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Paint the main series
    final mainPainter = mainSeries.createPainter();
    mainPainter.onPaint(
      canvas,
      size,
      xAxisModel.xFromEpoch,
      yAxisModel.yFromQuote,
    );
    
    // Paint the overlay series
    for (final series in overlaySeries) {
      final painter = series.createPainter();
      painter.onPaint(
        canvas,
        size,
        xAxisModel.xFromEpoch,
        yAxisModel.yFromQuote,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## Optimization Techniques

The rendering pipeline includes several optimization techniques:

### Binary Search for Visible Data

Binary search is used to efficiently find the visible data range:

```dart
int _binarySearchStartIndex(int leftEpoch) {
  int low = 0;
  int high = data.length - 1;
  
  while (low <= high) {
    final mid = (low + high) ~/ 2;
    final midEpoch = data[mid].epoch.millisecondsSinceEpoch;
    
    if (midEpoch < leftEpoch) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }
  
  return max(0, min(low, data.length - 1));
}
```

### Path Optimization

For line charts, paths are used instead of individual line segments:

```dart
// Inefficient approach (drawing individual lines)
for (int i = 1; i < data.length; i++) {
  canvas.drawLine(
    Offset(xFromEpoch(data[i-1].epoch), yFromQuote(data[i-1].quote)),
    Offset(xFromEpoch(data[i].epoch), yFromQuote(data[i].quote)),
    paint,
  );
}

// Efficient approach (using a path)
final path = Path();
path.moveTo(xFromEpoch(data.first.epoch), yFromQuote(data.first.quote));
for (int i = 1; i < data.length; i++) {
  path.lineTo(xFromEpoch(data[i].epoch), yFromQuote(data[i].quote));
}
canvas.drawPath(path, paint);
```

### Caching Indicator Values

Indicator values are cached to avoid recalculation:

```dart
List<Tick> _getIndicatorValues() {
  if (_cachedValues != null) return _cachedValues!;
  
  _cachedValues = _calculateIndicatorValues();
  return _cachedValues!;
}
```

### Viewport Clipping

Only elements within the viewport are rendered:

```dart
void onPaintData(
  Canvas canvas,
  Size size,
  List<T> data,
  double Function(DateTime) xFromEpoch,
  double Function(double) yFromQuote,
) {
  // Save the canvas state
  canvas.save();
  
  // Clip to the viewport
  canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
  
  // Paint the data
  // ...
  
  // Restore the canvas state
  canvas.restore();
}
```

## Rendering Flow

The complete rendering flow is as follows:

1. **Data Update**:
   - New data is received
   - Data is sorted chronologically
   - `updateVisibleRange` is called with the current viewport

2. **Viewport Update**:
   - User scrolls or zooms
   - `XAxisModel` updates `rightBoundEpoch` and `msPerPx`
   - `updateVisibleRange` is called with the new viewport

3. **Y-Axis Update**:
   - Visible data min/max values are calculated
   - Y-axis bounds are updated with padding
   - `quotePerPx` is recalculated

4. **Painting**:
   - Each layer's `CustomPaint` is triggered to repaint
   - Each layer's painter calls the appropriate `SeriesPainter`
   - Each `SeriesPainter` renders its content using the coordinate conversion functions

5. **Composition**:
   - Flutter composites all layers into the final chart
   - The chart is displayed on the screen

## Next Steps

Now that you understand the rendering pipeline used in the Deriv Chart library, you can explore:

- [Architecture](architecture.md) - Learn about the overall architecture of the library
- [Coordinate System](coordinate_system.md) - Understand how coordinates are managed
- [API Reference](../api_reference/chart_widget.md) - Explore the complete API