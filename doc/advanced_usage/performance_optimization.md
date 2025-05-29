# Performance Optimization

This document provides guidance on optimizing the performance of charts created with the Deriv Chart library, ensuring smooth rendering and interaction even with large datasets or on resource-constrained devices.

## Introduction

Financial charts often need to display large amounts of data while maintaining smooth scrolling, zooming, and interaction. The Deriv Chart library is designed with performance in mind, but there are several techniques you can use to further optimize your charts.

## Data Management Techniques

### Limit Visible Data

The most effective way to improve performance is to limit the amount of data being processed and rendered:

```dart
// Instead of passing all data to the chart
Chart(
  mainSeries: LineSeries(allTicks), // Could be thousands of points
  pipSize: 2,
)

// Only pass the data you need to display
Chart(
  mainSeries: LineSeries(visibleTicks), // Only the visible range
  pipSize: 2,
  onVisibleAreaChanged: (leftEpoch, rightEpoch) {
    // Load more data if needed
    loadDataForRange(leftEpoch, rightEpoch);
  },
)
```

### Data Downsampling

For very large datasets, consider downsampling the data to reduce the number of points:

```dart
List<Tick> downsampleTicks(List<Tick> ticks, int targetCount) {
  if (ticks.length <= targetCount) return ticks;
  
  final step = ticks.length / targetCount;
  final result = <Tick>[];
  
  for (int i = 0; i < ticks.length; i += step.round()) {
    result.add(ticks[i]);
  }
  
  return result;
}

// Use downsampled data for the chart
final downsampledTicks = downsampleTicks(allTicks, 500);
Chart(
  mainSeries: LineSeries(downsampledTicks),
  pipSize: 2,
)
```

### Lazy Loading

Implement lazy loading to fetch data only when needed:

```dart
class LazyLoadingChartExample extends StatefulWidget {
  @override
  State<LazyLoadingChartExample> createState() => _LazyLoadingChartExampleState();
}

class _LazyLoadingChartExampleState extends State<LazyLoadingChartExample> {
  List<Tick> _ticks = [];
  bool _isLoading = false;
  DateTime _oldestLoadedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Load the most recent data
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));
    
    final ticks = await fetchTickData(oneWeekAgo, now);
    
    setState(() {
      _ticks = ticks;
      _oldestLoadedDate = oneWeekAgo;
      _isLoading = false;
    });
  }
  
  Future<void> _loadMoreData(int leftEpoch) async {
    if (_isLoading) return;
    
    final leftDate = DateTime.fromMillisecondsSinceEpoch(leftEpoch);
    
    // Only load more data if we're near the edge of our loaded data
    if (leftDate.isAfter(_oldestLoadedDate.add(Duration(days: 1)))) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final newStartDate = _oldestLoadedDate.subtract(Duration(days: 7));
    final newTicks = await fetchTickData(newStartDate, _oldestLoadedDate);
    
    setState(() {
      _ticks = [...newTicks, ..._ticks];
      _oldestLoadedDate = newStartDate;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chart(
          mainSeries: LineSeries(_ticks),
          pipSize: 2,
          onVisibleAreaChanged: (leftEpoch, rightEpoch) {
            _loadMoreData(leftEpoch);
          },
        ),
        if (_isLoading)
          Positioned(
            left: 16,
            top: 16,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
  
  Future<List<Tick>> fetchTickData(DateTime start, DateTime end) async {
    // Implement your data fetching logic here
    // This could be an API call, database query, etc.
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return generateMockTickData(start, end);
  }
  
  List<Tick> generateMockTickData(DateTime start, DateTime end) {
    // Generate mock data for demonstration
    final result = <Tick>[];
    var current = start;
    double price = 100 + Random().nextDouble() * 10;
    
    while (current.isBefore(end)) {
      price += (Random().nextDouble() - 0.5) * 2;
      result.add(Tick(epoch: current, quote: price));
      current = current.add(Duration(minutes: 5));
    }
    
    return result;
  }
}
```

## Rendering Optimizations

### Use RepaintBoundary

Wrap your chart in a `RepaintBoundary` to isolate its rendering from the rest of your UI:

```dart
RepaintBoundary(
  child: Chart(
    mainSeries: LineSeries(ticks),
    pipSize: 2,
  ),
)
```

### Optimize Chart Size

Larger charts require more rendering resources. Consider using a smaller chart size or implementing responsive sizing:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // Limit the chart height based on available space
    final chartHeight = min(constraints.maxHeight, 400.0);
    
    return SizedBox(
      height: chartHeight,
      child: Chart(
        mainSeries: LineSeries(ticks),
        pipSize: 2,
      ),
    );
  },
)
```

### Reduce Indicator Count

Each indicator adds computational and rendering overhead. Limit the number of indicators displayed simultaneously:

```dart
// Instead of many indicators
Chart(
  mainSeries: CandleSeries(candles),
  overlayConfigs: [
    BollingerBandsIndicatorConfig(),
    MAIndicatorConfig(period: 14),
    MAIndicatorConfig(period: 50),
    MAIndicatorConfig(period: 200),
  ],
  bottomConfigs: [
    RSIIndicatorConfig(),
    MACDIndicatorConfig(),
    StochasticIndicatorConfig(),
  ],
  pipSize: 2,
)

// Limit to the most important indicators
Chart(
  mainSeries: CandleSeries(candles),
  overlayConfigs: [
    MAIndicatorConfig(period: 50),
  ],
  bottomConfigs: [
    RSIIndicatorConfig(),
  ],
  pipSize: 2,
)
```

### Simplify Drawing Tools

Complex drawing tools can impact performance. Use simpler tools or limit the number of active drawing tools:

```dart
// Implement a limit on the number of drawing tools
class LimitedDrawingToolsExample extends StatefulWidget {
  @override
  State<LimitedDrawingToolsExample> createState() => _LimitedDrawingToolsExampleState();
}

class _LimitedDrawingToolsExampleState extends State<LimitedDrawingToolsExample> {
  final _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
    createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
    onEditCallback: (int index) {},
    sharedPrefKey: 'drawing_tools',
  );
  
  static const int _maxDrawingTools = 10;
  
  @override
  Widget build(BuildContext context) {
    return DerivChart(
      mainSeries: CandleSeries(candles),
      drawingToolsRepo: _drawingToolsRepo,
      onDrawingToolAdded: (DrawingToolConfig config) {
        // Check if we've reached the limit
        if (_drawingToolsRepo.items.length > _maxDrawingTools) {
          // Remove the oldest drawing tool
          _drawingToolsRepo.removeAt(0);
          
          // Show a notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum number of drawing tools reached. Oldest tool removed.'),
            ),
          );
        }
      },
    );
  }
}
```

## Device-Specific Optimizations

### Detect Device Capabilities

Adjust chart complexity based on device capabilities:

```dart
bool isLowEndDevice() {
  // This is a simplified example. In a real app, you would use more
  // sophisticated detection based on device model, available memory, etc.
  return Platform.isAndroid && 
         (defaultTargetPlatform == TargetPlatform.android) && 
         !kIsWeb;
}

Widget buildChartBasedOnDevice() {
  final isLowEnd = isLowEndDevice();
  
  return Chart(
    mainSeries: LineSeries(ticks),
    pipSize: 2,
    showGrid: !isLowEnd, // Disable grid on low-end devices
    showCrosshair: !isLowEnd, // Disable crosshair on low-end devices
    // Reduce other visual elements for low-end devices
  );
}
```

### Optimize for Web

When deploying to web, consider additional optimizations:

```dart
bool isWebPlatform() {
  return kIsWeb;
}

Widget buildChartForWeb() {
  final isWeb = isWebPlatform();
  
  // For web, use a more aggressive data downsampling
  final optimizedTicks = isWeb ? downsampleTicks(ticks, 300) : ticks;
  
  return Chart(
    mainSeries: LineSeries(optimizedTicks),
    pipSize: 2,
  );
}
```

## Memory Management

### Dispose Controllers

Always dispose of chart controllers when they're no longer needed:

```dart
class ChartScreenState extends State<ChartScreen> {
  final _chartController = ChartController();
  
  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(ticks),
      pipSize: 2,
      controller: _chartController,
    );
  }
}
```

### Clear Unused Data

Clear data that's no longer needed to free up memory:

```dart
void clearOldData() {
  // Keep only the last 1000 ticks
  if (allTicks.length > 1000) {
    allTicks = allTicks.sublist(allTicks.length - 1000);
  }
}
```

## Measuring Performance

### Use Performance Overlay

Flutter's performance overlay can help identify rendering issues:

```dart
MaterialApp(
  showPerformanceOverlay: true,
  home: Scaffold(
    body: Chart(
      mainSeries: LineSeries(ticks),
      pipSize: 2,
    ),
  ),
)
```

### Profile with DevTools

Use Flutter DevTools to profile your app and identify performance bottlenecks:

1. Run your app in debug mode
2. Open DevTools
3. Use the Performance tab to record and analyze performance

### Custom Performance Metrics

Implement custom performance metrics to track chart performance:

```dart
class PerformanceMetricsExample extends StatefulWidget {
  @override
  State<PerformanceMetricsExample> createState() => _PerformanceMetricsExampleState();
}

class _PerformanceMetricsExampleState extends State<PerformanceMetricsExample> {
  int _frameCount = 0;
  double _averageFrameTime = 0;
  Stopwatch _stopwatch = Stopwatch();
  
  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    
    // Set up a timer to calculate FPS
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _averageFrameTime = _frameCount > 0 
              ? _stopwatch.elapsedMilliseconds / _frameCount 
              : 0;
          _frameCount = 0;
          _stopwatch.reset();
          _stopwatch.start();
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chart(
          mainSeries: LineSeries(ticks),
          pipSize: 2,
          onPaint: () {
            // Increment frame count each time the chart is painted
            _frameCount++;
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.7),
            child: Text(
              'Avg frame time: ${_averageFrameTime.toStringAsFixed(2)} ms',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
```

## Best Practices

1. **Start simple and add complexity as needed**: Begin with a basic chart and add features incrementally
2. **Test on target devices**: Always test performance on the actual devices your users will use
3. **Monitor memory usage**: Keep an eye on memory usage, especially with large datasets
4. **Use efficient data structures**: Choose appropriate data structures for your use case
5. **Implement pagination**: For historical data, implement pagination to load data in chunks
6. **Optimize UI updates**: Minimize setState calls and use more granular state management
7. **Consider using compute for heavy calculations**: Move heavy calculations to a separate isolate

## Next Steps

Now that you understand how to optimize the performance of your charts, you can explore:

- [Real-time Data](real_time_data.md) - Learn how to handle real-time data updates
- [Custom Indicators](custom_indicators.md) - Create efficient custom indicators
- [Custom Drawing Tools](custom_drawing_tools.md) - Implement optimized drawing tools