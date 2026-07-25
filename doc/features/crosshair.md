# Crosshair

This document explains how to use and customize the crosshair feature in the Deriv Chart library, which provides precise data inspection capabilities.

## Introduction to Crosshair

The crosshair is a tool that helps users inspect specific data points on a chart. It consists of horizontal and vertical lines that intersect at the point of interest, along with labels showing the exact time and price values at that point.

In the Deriv Chart library, the crosshair is activated by a long press on the chart and can be customized to suit different needs.

## Basic Usage

By default, the crosshair is enabled in the Chart widget:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  // Crosshair is enabled by default
)
```

You can explicitly enable or disable the crosshair:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  showCrosshair: true, // or false to disable
)
```

## Crosshair Behavior

The crosshair in the Deriv Chart library has the following behavior:

1. **Activation**: The crosshair is activated by a long press on the chart
2. **Movement**: Once activated, the crosshair follows the user's finger or cursor as they move across the chart
3. **Deactivation**: The crosshair is deactivated when the user releases their finger or cursor
4. **Data Display**: The crosshair shows the exact time and price values at the intersection point
5. **Snap to Data**: The crosshair can snap to the nearest data point for more precise inspection

## Customizing Crosshair Appearance

You can customize the appearance of the crosshair by providing a custom theme with a `CrosshairStyle`:

```dart
class CustomTheme extends ChartDefaultDarkTheme {
  @override
  CrosshairStyle get crosshairStyle => CrosshairStyle(
    lineColor: Colors.orange,
    lineThickness: 1,
    lineDashPattern: [5, 5], // Dashed line
    labelBackgroundColor: Colors.orange.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    labelBorderRadius: 4,
  );
}

// Using the custom theme
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  theme: CustomTheme(),
)
```

## Crosshair Callbacks

The Chart widget provides callbacks to respond to crosshair events:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  onCrosshairAppeared: () {
    print('Crosshair appeared');
    // Provide haptic feedback or update UI
    HapticFeedback.lightImpact();
  },
  onCrosshairDisappeared: () {
    print('Crosshair disappeared');
    // Update UI or perform cleanup
  },
)
```

These callbacks are useful for:
- Providing haptic feedback when the crosshair appears
- Updating other UI elements based on crosshair state
- Logging user interactions for analytics

## Crosshair with Multiple Charts

When using multiple charts (main chart and bottom charts), the crosshair is synchronized across all charts:

```dart
Chart(
  mainSeries: CandleSeries(candles),
  bottomConfigs: [
    RSIIndicatorConfig(period: 14),
    MACDIndicatorConfig(),
  ],
  pipSize: 2,
  // Crosshair will be synchronized across all charts
)
```

This synchronization ensures that:
1. The vertical line of the crosshair aligns across all charts
2. Each chart shows its own horizontal line and price label
3. Only one time label is shown (typically at the bottom)

## Crosshair Data Inspection

The crosshair helps users inspect data in several ways:

### Price Inspection

The horizontal line and label show the exact price at the crosshair position:

```
Price: 125.50
```

### Time Inspection

The vertical line and label show the exact time at the crosshair position:

```
Time: 2023-01-15 12:30:45
```

### Data Point Inspection

When the crosshair snaps to a data point, it can show additional information about that point:

For candlestick charts:
```
O: 125.00  H: 126.50
L: 124.75  C: 125.50
```

For indicator charts:
```
RSI: 65.75
```

## Implementing Custom Crosshair Behavior

You can implement custom crosshair behavior by combining the crosshair with other features:

### Example: Displaying Detailed Information in a Tooltip

```dart
class CrosshairTooltipExample extends StatefulWidget {
  final List<Candle> candles;
  
  const CrosshairTooltipExample({
    Key? key,
    required this.candles,
  }) : super(key: key);
  
  @override
  State<CrosshairTooltipExample> createState() => _CrosshairTooltipExampleState();
}

class _CrosshairTooltipExampleState extends State<CrosshairTooltipExample> {
  Candle? _selectedCandle;
  Offset? _tooltipPosition;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chart(
          mainSeries: CandleSeries(widget.candles),
          pipSize: 2,
          onLongPressStart: (details) {
            _updateSelectedCandle(details.localPosition);
          },
          onLongPressMoveUpdate: (details) {
            _updateSelectedCandle(details.localPosition);
          },
          onLongPressEnd: (details) {
            setState(() {
              _selectedCandle = null;
              _tooltipPosition = null;
            });
          },
        ),
        if (_selectedCandle != null && _tooltipPosition != null)
          Positioned(
            left: _tooltipPosition!.dx + 10,
            top: _tooltipPosition!.dy - 70,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Date: ${_formatDate(_selectedCandle!.epoch)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Open: ${_selectedCandle!.open.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'High: ${_selectedCandle!.high.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Low: ${_selectedCandle!.low.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Close: ${_selectedCandle!.close.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  void _updateSelectedCandle(Offset position) {
    // Find the candle at the position
    // This is a simplified example - in a real app, you would use the chart's
    // coordinate conversion functions to find the exact candle
    final index = (position.dx / context.size!.width * widget.candles.length).floor();
    if (index >= 0 && index < widget.candles.length) {
      setState(() {
        _selectedCandle = widget.candles[index];
        _tooltipPosition = position;
      });
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

### Example: Synchronizing Crosshair Between Multiple Charts

```dart
class SynchronizedCrosshairExample extends StatefulWidget {
  final List<Candle> candles;
  
  const SynchronizedCrosshairExample({
    Key? key,
    required this.candles,
  }) : super(key: key);
  
  @override
  State<SynchronizedCrosshairExample> createState() => _SynchronizedCrosshairExampleState();
}

class _SynchronizedCrosshairExampleState extends State<SynchronizedCrosshairExample> {
  final _controller1 = ChartController();
  final _controller2 = ChartController();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Chart(
            mainSeries: CandleSeries(widget.candles),
            pipSize: 2,
            controller: _controller1,
            onVisibleAreaChanged: (leftEpoch, rightEpoch) {
              // Synchronize the visible area of the second chart
              _controller2.scrollTo(DateTime.fromMillisecondsSinceEpoch(leftEpoch));
              _controller2.scale(_controller1.msPerPx);
            },
          ),
        ),
        Expanded(
          child: Chart(
            mainSeries: LineSeries(widget.candles.map((c) => Tick(epoch: c.epoch, quote: c.close)).toList()),
            pipSize: 2,
            controller: _controller2,
            onVisibleAreaChanged: (leftEpoch, rightEpoch) {
              // Synchronize the visible area of the first chart
              _controller1.scrollTo(DateTime.fromMillisecondsSinceEpoch(leftEpoch));
              _controller1.scale(_controller2.msPerPx);
            },
          ),
        ),
      ],
    );
  }
}
```

## Best Practices

When using the crosshair feature, consider the following best practices:

1. **Provide feedback**: Use the `onCrosshairAppeared` callback to provide haptic feedback when the crosshair appears
2. **Customize appearance**: Customize the crosshair appearance to match your app's theme
3. **Consider visibility**: Ensure the crosshair is visible against the chart background
4. **Enhance with tooltips**: Consider adding custom tooltips to provide more detailed information
5. **Test on different devices**: Test the crosshair behavior on different devices and screen sizes

## Next Steps

Now that you understand how to use the crosshair feature in the Deriv Chart library, you can explore:

- [Annotations](annotations.md) - Learn how to use annotations to highlight specific areas
- [Markers](markers.md) - Learn how to use markers to highlight specific points
- [Drawing Tools](drawing_tools/overview.md) - Explore interactive drawing tools for technical analysis