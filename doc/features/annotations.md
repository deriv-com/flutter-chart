# Chart Annotations

This document explains how to use annotations in the Deriv Chart library to highlight specific price levels, time points, and other significant areas on the chart.

## Introduction to Annotations

Annotations are visual elements added to a chart to highlight important information. Unlike drawing tools, which are interactive and can be manipulated by users, annotations are typically static elements that are programmatically added to the chart.

The Deriv Chart library provides several types of annotations:
- Horizontal barriers (price levels)
- Vertical barriers (time points)
- Tick indicators (specific data points)

## Horizontal Barriers

Horizontal barriers are horizontal lines that highlight specific price levels on the chart. They are commonly used to mark support and resistance levels, target prices, or entry and exit points.

### Basic Usage

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    HorizontalBarrier(
      125.50, // Price level
      title: 'Resistance', // Optional label
    ),
  ],
)
```

### Customizing Horizontal Barriers

You can customize the appearance of horizontal barriers using the `HorizontalBarrierStyle` class:

```dart
HorizontalBarrier(
  125.50,
  title: 'Resistance',
  style: HorizontalBarrierStyle(
    color: Colors.red,
    isDashed: true,
    lineThickness: 1.5,
    labelBackgroundColor: Colors.red.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Controlling Visibility Behavior

You can control how horizontal barriers behave when they are outside the visible price range using the `visibility` parameter:

```dart
HorizontalBarrier(
  125.50,
  title: 'Resistance',
  visibility: HorizontalBarrierVisibility.forceToStayOnRange,
)
```

Available visibility options:
- `HorizontalBarrierVisibility.normal`: The barrier is only visible when its price level is within the visible range
- `HorizontalBarrierVisibility.forceToStayOnRange`: The barrier is always visible, even if its price level is outside the visible range (it will be shown at the edge of the chart)

## Vertical Barriers

Vertical barriers are vertical lines that highlight specific time points on the chart. They are commonly used to mark significant events, announcements, or trading sessions.

### Basic Usage

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    VerticalBarrier(
      DateTime(2023, 1, 15, 12, 0), // Time point
      title: 'Market Open', // Optional label
    ),
  ],
)
```

### Customizing Vertical Barriers

You can customize the appearance of vertical barriers using the `VerticalBarrierStyle` class:

```dart
VerticalBarrier(
  DateTime(2023, 1, 15, 12, 0),
  title: 'Market Open',
  style: VerticalBarrierStyle(
    color: Colors.blue,
    isDashed: true,
    lineThickness: 1.5,
    labelBackgroundColor: Colors.blue.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

## Tick Indicators

Tick indicators are special annotations that highlight specific data points on the chart. They combine a horizontal barrier with a marker to show a specific tick's price and time.

### Basic Usage

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    TickIndicator(
      ticks.last, // The tick to highlight
    ),
  ],
)
```

### Customizing Tick Indicators

Tick indicators are a subclass of `HorizontalBarrier`, so they can be customized in the same way:

```dart
TickIndicator(
  ticks.last,
  style: HorizontalBarrierStyle(
    color: Colors.green,
    isDashed: false,
    lineThickness: 1.5,
    labelBackgroundColor: Colors.green.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

By default, tick indicators use `HorizontalBarrierVisibility.forceToStayOnRange` to ensure they are always visible.

## Multiple Annotations

You can add multiple annotations to a chart by including them in the `annotations` list:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    // Horizontal barriers
    HorizontalBarrier(125.50, title: 'Resistance'),
    HorizontalBarrier(115.75, title: 'Support'),
    
    // Vertical barriers
    VerticalBarrier(DateTime(2023, 1, 15, 12, 0), title: 'Market Open'),
    VerticalBarrier(DateTime(2023, 1, 15, 20, 0), title: 'Market Close'),
    
    // Tick indicator
    TickIndicator(ticks.last),
  ],
)
```

## Dynamic Annotations

You can dynamically update annotations based on data changes or user interactions:

```dart
class DynamicAnnotationsExample extends StatefulWidget {
  final List<Tick> ticks;
  
  const DynamicAnnotationsExample({
    Key? key,
    required this.ticks,
  }) : super(key: key);
  
  @override
  State<DynamicAnnotationsExample> createState() => _DynamicAnnotationsExampleState();
}

class _DynamicAnnotationsExampleState extends State<DynamicAnnotationsExample> {
  late List<ChartAnnotation> _annotations;
  
  @override
  void initState() {
    super.initState();
    _updateAnnotations();
  }
  
  void _updateAnnotations() {
    // Calculate average price
    double sum = 0;
    for (final tick in widget.ticks) {
      sum += tick.quote;
    }
    final averagePrice = sum / widget.ticks.length;
    
    // Create annotations
    _annotations = [
      HorizontalBarrier(
        averagePrice,
        title: 'Average: ${averagePrice.toStringAsFixed(2)}',
        style: HorizontalBarrierStyle(
          color: Colors.purple,
          isDashed: true,
        ),
      ),
      TickIndicator(widget.ticks.last),
    ];
  }
  
  @override
  void didUpdateWidget(DynamicAnnotationsExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ticks != oldWidget.ticks) {
      _updateAnnotations();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(widget.ticks),
      pipSize: 2,
      annotations: _annotations,
    );
  }
}
```

## Custom Annotations

You can create custom annotations by extending the `ChartAnnotation` class:

```dart
class RangeAnnotation extends ChartAnnotation {
  final double upperValue;
  final double lowerValue;
  final String? title;
  final Color color;
  
  RangeAnnotation({
    required this.upperValue,
    required this.lowerValue,
    this.title,
    this.color = Colors.blue,
    super.id,
  });
  
  @override
  ChartObject createObject() {
    return RangeObject(
      upperValue: upperValue,
      lowerValue: lowerValue,
      title: title,
    );
  }
  
  @override
  SeriesPainter createPainter() {
    return RangeAnnotationPainter(this);
  }
}

class RangeObject extends ChartObject {
  final double upperValue;
  final double lowerValue;
  final String? title;
  
  RangeObject({
    required this.upperValue,
    required this.lowerValue,
    this.title,
  });
  
  @override
  bool isOnValueRange(double minValue, double maxValue) {
    return upperValue >= minValue || lowerValue <= maxValue;
  }
  
  @override
  bool isOnEpochRange(int minEpoch, int maxEpoch) {
    return true; // Range spans the entire x-axis
  }
}

class RangeAnnotationPainter extends SeriesPainter {
  final RangeAnnotation annotation;
  
  RangeAnnotationPainter(this.annotation) : super(annotation);
  
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    double Function(DateTime) xFromEpoch,
    double Function(double) yFromQuote,
  ) {
    final upperY = yFromQuote(annotation.upperValue);
    final lowerY = yFromQuote(annotation.lowerValue);
    
    // Draw the range rectangle
    final paint = Paint()
      ..color = annotation.color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromPoints(
        Offset(0, upperY),
        Offset(size.width, lowerY),
      ),
      paint,
    );
    
    // Draw the range borders
    final borderPaint = Paint()
      ..color = annotation.color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, upperY),
      Offset(size.width, upperY),
      borderPaint,
    );
    
    canvas.drawLine(
      Offset(0, lowerY),
      Offset(size.width, lowerY),
      borderPaint,
    );
    
    // Draw the title if provided
    if (annotation.title != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: annotation.title,
          style: TextStyle(
            color: annotation.color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(10, upperY + 5),
      );
    }
  }
}
```

Usage of the custom annotation:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    RangeAnnotation(
      upperValue: 130.0,
      lowerValue: 120.0,
      title: 'Trading Range',
      color: Colors.orange,
    ),
  ],
)
```

## Best Practices

When using annotations, consider the following best practices:

1. **Use sparingly**: Too many annotations can clutter the chart and make it difficult to read
2. **Use consistent styling**: Use consistent colors and styles for similar types of annotations
3. **Provide clear labels**: Use descriptive labels to explain the significance of each annotation
4. **Update dynamically**: Update annotations when relevant data changes
5. **Consider visibility**: Ensure annotations are visible against the chart background

## Next Steps

Now that you understand how to use annotations in the Deriv Chart library, you can explore:

- [Markers](markers.md) - Learn how to use markers to highlight specific points
- [Crosshair](crosshair.md) - Understand how to use the crosshair for precise data inspection
- [Drawing Tools](drawing_tools/overview.md) - Explore interactive drawing tools for technical analysis