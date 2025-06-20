# Rendering Pipeline

This document explains the rendering pipeline used in the Deriv Chart library, detailing how data flows from raw market data to visual elements on the screen.

## Overview

The rendering pipeline in the Deriv Chart library consists of several stages:

1. **Data Processing**: Preparing and filtering data for visualization
2. **Coordinate Mapping**: Converting data points to screen coordinates
3. **Painting**: Drawing the visual elements on the canvas
4. **Composition**: Combining multiple layers into the final chart

This pipeline ensures efficient rendering and a responsive user experience, even with large datasets.

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

## Data Processing Stage

The data processing stage prepares the raw market data for visualization:

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
   - Each `ChartData` implementation's `update(leftEpoch, rightEpoch)` method is called
   - Each implementation calculates its visible data subset based on the current viewport

2. **Y-Axis Update**:
   - Each `ChartData` implementation calculates its `minValue` and `maxValue` for the visible data
   - The chart collects these values using the `ChartDataListExtension` methods:
     ```dart
     double getMinValue() {
       final Iterable<double> minValues =
           where((ChartData? c) => c != null && !c.minValue.isNaN)
               .map((ChartData? c) => c!.minValue);
       return minValues.isEmpty ? double.nan : minValues.reduce(min);
     }
     
     double getMaxValue() {
       final Iterable<double> maxValues =
           where((ChartData? c) => c != null && !c.maxValue.isNaN)
               .map((ChartData? c) => c!.maxValue);
       return maxValues.isEmpty ? double.nan : maxValues.reduce(max);
     }
     ```
   - Y-axis bounds are updated with padding
   - `quotePerPx` is recalculated

4. **Painting**:
   - Each layer's `CustomPaint` is triggered to repaint
   - The chart calls the `paint` method on each of its `ChartData` objects:
     ```dart
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
     ```
   - Each `ChartData` implementation renders its content using the coordinate conversion functions

5. **Composition**:
   - Flutter composites all layers into the final chart
   - The chart is displayed on the screen

## Painter Classes

The Deriv Chart library uses a decoupled painter architecture to promote code reuse:

1. **Specialized Painters**: Each visual element type has specialized painters:
   - `LinePainter`: Renders line graphs (used by LineSeries and many indicators)
   - `CandlePainter`: Renders candlestick charts
   - `OHLCPainter`: Renders OHLC charts
   - `HorizontalBarrierPainter`: Renders horizontal barriers
   - `VerticalBarrierPainter`: Renders vertical barriers
   - `MarkerPainter`: Renders markers

2. **Painter Reuse**: The same painter can be used by different `ChartData` implementations:
   - `LinePainter` is used by LineSeries, Moving Average indicators, and other line-based indicators
   - This approach ensures consistent rendering across different chart elements

3. **Painter Composition**: Complex chart elements can use multiple painters:
   - Bollinger Bands uses both `LinePainter` (for the middle line) and specialized painters for the bands
   - MACD uses `LinePainter` for signal line and histogram painters for the bars

This decoupled approach allows for:
- Better code organization
- Easier maintenance
- Consistent visual appearance
- Code reuse across different chart elements

## Next Steps

Now that you understand the rendering pipeline used in the Deriv Chart library, you can explore:

- [Architecture](architecture.md) - Learn about the overall architecture of the library
- [Coordinate System](coordinate_system.md) - Understand how coordinates are managed
- [API Reference](../api_reference/chart_widget.md) - Explore the complete API