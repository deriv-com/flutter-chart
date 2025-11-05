# Chart Markers

This document explains how to use markers in the Deriv Chart library to highlight specific points on the chart and enable user interactions with those points.

## Introduction to Markers

Markers are visual elements that highlight specific data points on a chart. Unlike annotations, which typically span across the chart (like horizontal or vertical lines), markers are attached to specific data points and can respond to user interactions.

The Deriv Chart library provides several types of markers:
- Standard markers (up, down, neutral)
- Active markers (highlighted markers with special interaction behavior)
- Entry and exit tick markers

## MarkerSeries

All markers are managed through the `MarkerSeries` class, which is passed to the `Chart` widget:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries([
    // List of markers
  ]),
)
```

## Standard Markers

Standard markers highlight specific data points on the chart. They can be configured with different styles and can respond to user interactions.

### Basic Usage

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries([
    Marker.up(
      epoch: ticks[5].epoch,
      quote: ticks[5].quote,
      onTap: () {
        print('Up marker tapped');
      },
    ),
    Marker.down(
      epoch: ticks[10].epoch,
      quote: ticks[10].quote,
      onTap: () {
        print('Down marker tapped');
      },
    ),
    Marker.neutral(
      epoch: ticks[15].epoch,
      quote: ticks[15].quote,
      onTap: () {
        print('Neutral marker tapped');
      },
    ),
  ]),
)
```

### Marker Types

The Deriv Chart library provides three types of standard markers:

1. **Up Marker**: Typically used to indicate a positive event or an entry point
   ```dart
   Marker.up(
     epoch: DateTime.now(),
     quote: 125.50,
     onTap: () {},
   )
   ```

2. **Down Marker**: Typically used to indicate a negative event or an exit point
   ```dart
   Marker.down(
     epoch: DateTime.now(),
     quote: 120.75,
     onTap: () {},
   )
   ```

3. **Neutral Marker**: Used for general points of interest
   ```dart
   Marker.neutral(
     epoch: DateTime.now(),
     quote: 123.00,
     onTap: () {},
   )
   ```

### Customizing Markers

You can customize markers by providing a custom `MarkerStyle`:

```dart
Marker.up(
  epoch: ticks[5].epoch,
  quote: ticks[5].quote,
  style: MarkerStyle(
    color: Colors.green,
    size: 12,
    borderWidth: 2,
    borderColor: Colors.white,
  ),
  onTap: () {},
)
```

## Active Marker

An active marker is a special marker that is highlighted and can have additional interaction behaviors. Typically, only one marker can be active at a time.

### Basic Usage

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [
      // Standard markers
      Marker.up(epoch: ticks[5].epoch, quote: ticks[5].quote, onTap: () {}),
      Marker.down(epoch: ticks[10].epoch, quote: ticks[10].quote, onTap: () {}),
    ],
    // Active marker
    activeMarker: ActiveMarker(
      epoch: ticks[5].epoch,
      quote: ticks[5].quote,
      onTap: () {
        print('Active marker tapped');
      },
      onOutsideTap: () {
        print('Tapped outside active marker');
        // Remove active marker
      },
    ),
  ),
)
```

### Active Marker Properties

The `ActiveMarker` class has the following properties:

- `epoch`: The timestamp of the marker
- `quote`: The price level of the marker
- `onTap`: Callback when the marker is tapped
- `onOutsideTap`: Callback when the user taps outside the marker

### Dynamic Active Marker

You can dynamically update the active marker based on user interactions:

```dart
class DynamicMarkerExample extends StatefulWidget {
  final List<Tick> ticks;
  
  const DynamicMarkerExample({
    Key? key,
    required this.ticks,
  }) : super(key: key);
  
  @override
  State<DynamicMarkerExample> createState() => _DynamicMarkerExampleState();
}

class _DynamicMarkerExampleState extends State<DynamicMarkerExample> {
  ActiveMarker? _activeMarker;
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(widget.ticks),
      pipSize: 2,
      markerSeries: MarkerSeries(
        widget.ticks.asMap().entries.map((entry) {
          final index = entry.key;
          final tick = entry.value;
          
          // Add a marker every 5 ticks
          if (index % 5 == 0) {
            return Marker.neutral(
              epoch: tick.epoch,
              quote: tick.quote,
              onTap: () {
                setState(() {
                  _activeMarker = ActiveMarker(
                    epoch: tick.epoch,
                    quote: tick.quote,
                    onTap: () {
                      print('Active marker tapped');
                    },
                    onOutsideTap: () {
                      setState(() {
                        _activeMarker = null;
                      });
                    },
                  );
                });
              },
            );
          }
          return null;
        }).whereType<Marker>().toList(),
        activeMarker: _activeMarker,
      ),
    );
  }
}
```

## Entry and Exit Tick Markers

Entry and exit tick markers are special markers that highlight the entry and exit points of a trade or analysis period.

### Basic Usage

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [], // No standard markers
    entryTick: Tick(
      epoch: ticks.first.epoch,
      quote: ticks.first.quote,
    ),
    exitTick: Tick(
      epoch: ticks.last.epoch,
      quote: ticks.last.quote,
    ),
  ),
)
```

### Customizing Entry and Exit Tick Markers

You can customize the appearance of entry and exit tick markers by providing custom styles:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [],
    entryTick: Tick(
      epoch: ticks.first.epoch,
      quote: ticks.first.quote,
    ),
    exitTick: Tick(
      epoch: ticks.last.epoch,
      quote: ticks.last.quote,
    ),
    entryTickStyle: MarkerStyle(
      color: Colors.green,
      size: 10,
      borderWidth: 2,
      borderColor: Colors.white,
    ),
    exitTickStyle: MarkerStyle(
      color: Colors.red,
      size: 10,
      borderWidth: 2,
      borderColor: Colors.white,
    ),
  ),
)
```

## Combining Different Marker Types

You can combine different types of markers in a single chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [
      // Standard markers
      Marker.up(epoch: ticks[5].epoch, quote: ticks[5].quote, onTap: () {}),
      Marker.down(epoch: ticks[10].epoch, quote: ticks[10].quote, onTap: () {}),
    ],
    // Active marker
    activeMarker: ActiveMarker(
      epoch: ticks[5].epoch,
      quote: ticks[5].quote,
      onTap: () {},
      onOutsideTap: () {},
    ),
    // Entry and exit ticks
    entryTick: Tick(
      epoch: ticks.first.epoch,
      quote: ticks.first.quote,
    ),
    exitTick: Tick(
      epoch: ticks.last.epoch,
      quote: ticks.last.quote,
    ),
  ),
)
```

## Markers with Real-Time Data

When working with real-time data, you can update markers as new data arrives:

```dart
class RealTimeMarkerExample extends StatefulWidget {
  final Stream<Tick> tickStream;
  
  const RealTimeMarkerExample({
    Key? key,
    required this.tickStream,
  }) : super(key: key);
  
  @override
  State<RealTimeMarkerExample> createState() => _RealTimeMarkerExampleState();
}

class _RealTimeMarkerExampleState extends State<RealTimeMarkerExample> {
  final List<Tick> _ticks = [];
  final List<Marker> _markers = [];
  
  @override
  void initState() {
    super.initState();
    widget.tickStream.listen(_onNewTick);
  }
  
  void _onNewTick(Tick tick) {
    setState(() {
      _ticks.add(tick);
      
      // Add a marker for significant price movements
      if (_ticks.length > 1) {
        final previousTick = _ticks[_ticks.length - 2];
        final priceDifference = tick.quote - previousTick.quote;
        
        if (priceDifference.abs() > 1.0) {
          _markers.add(
            priceDifference > 0
                ? Marker.up(
                    epoch: tick.epoch,
                    quote: tick.quote,
                    onTap: () {},
                  )
                : Marker.down(
                    epoch: tick.epoch,
                    quote: tick.quote,
                    onTap: () {},
                  ),
          );
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(_ticks),
      pipSize: 2,
      markerSeries: MarkerSeries(_markers),
    );
  }
}
```

## Custom Markers

You can create custom markers by extending the `Marker` class:

```dart
class CustomMarker extends Marker {
  final IconData icon;
  final Color color;
  
  CustomMarker({
    required DateTime epoch,
    required double quote,
    required this.icon,
    required this.color,
    VoidCallback? onTap,
  }) : super(
    epoch: epoch,
    quote: quote,
    type: MarkerType.neutral, // Use neutral as base type
    onTap: onTap,
  );
  
  // Override the paint method to customize the marker appearance
  @override
  void paint(Canvas canvas, Offset center, double scale) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw a circle background
    canvas.drawCircle(center, 10 * scale, paint);
    
    // Draw the icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * scale,
          fontFamily: icon.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
}
```

Usage of the custom marker:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries([
    CustomMarker(
      epoch: ticks[5].epoch,
      quote: ticks[5].quote,
      icon: Icons.star,
      color: Colors.orange,
      onTap: () {
        print('Star marker tapped');
      },
    ),
    CustomMarker(
      epoch: ticks[10].epoch,
      quote: ticks[10].quote,
      icon: Icons.warning,
      color: Colors.red,
      onTap: () {
        print('Warning marker tapped');
      },
    ),
  ]),
)
```

## Best Practices

When using markers, consider the following best practices:

1. **Use sparingly**: Too many markers can clutter the chart and make it difficult to read
2. **Provide interaction feedback**: Use the `onTap` callback to provide feedback when a marker is tapped
3. **Use appropriate marker types**: Use up markers for positive events, down markers for negative events, and neutral markers for general points of interest
4. **Consider visibility**: Ensure markers are visible against the chart background
5. **Handle edge cases**: Ensure markers are still visible when they are at the edges of the chart

## Next Steps

Now that you understand how to use markers in the Deriv Chart library, you can explore:

- [Annotations](annotations.md) - Learn how to use annotations to highlight specific areas
- [Crosshair](crosshair.md) - Understand how to use the crosshair for precise data inspection
- [Drawing Tools](drawing_tools/overview.md) - Explore interactive drawing tools for technical analysis