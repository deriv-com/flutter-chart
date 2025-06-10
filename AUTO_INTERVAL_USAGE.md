# Auto Interval Wrapper Usage

The `AutoIntervalWrapper` provides a simplified way to add automatic granularity switching to your charts based on zoom levels. It follows the same wrapper pattern as `GestureManager` and `XAxisWrapper`.

**✨ Fully Self-Contained**: No separate manager classes needed - all logic is built directly into the wrapper!

## Basic Usage

### With Chart Widget

```dart
import 'package:deriv_chart/deriv_chart.dart';

// Wrap your chart with AutoIntervalWrapper
AutoIntervalWrapper(
  enabled: true,
  granularity: currentGranularity, // in milliseconds
  zoomRanges: const [
    AutoIntervalZoomRange(
      granularity: 60000,  // 1 minute
      minPixelsPerInterval: 20,
      maxPixelsPerInterval: 120,
      optimalPixelsPerInterval: 40,
    ),
    AutoIntervalZoomRange(
      granularity: 300000, // 5 minutes
      minPixelsPerInterval: 20,
      maxPixelsPerInterval: 120,
      optimalPixelsPerInterval: 40,
    ),
    // Add more ranges as needed
  ],
  onGranularityChangeRequested: (int suggestedGranularity) {
    // Handle granularity change request
    print('Auto-interval suggests: ${suggestedGranularity}ms');
    
    // Update your data and granularity
    updateChartGranularity(suggestedGranularity ~/ 1000); // Convert to seconds
  },
  child: Chart(
    mainSeries: yourDataSeries,
    granularity: currentGranularity,
    // ... other chart properties
  ),
)
```

### With DerivChart Widget

```dart
AutoIntervalWrapper(
  enabled: true,
  granularity: currentGranularity,
  zoomRanges: defaultAutoIntervalRanges, // Use predefined ranges
  onGranularityChangeRequested: (int suggestedGranularity) {
    // Handle the suggestion
    final int suggestedGranularitySeconds = suggestedGranularity ~/ 1000;
    
    if (suggestedGranularitySeconds != currentGranularitySeconds) {
      // Update granularity and fetch new data
      fetchNewData(suggestedGranularitySeconds);
    }
  },
  child: DerivChart(
    mainSeries: yourDataSeries,
    granularity: currentGranularity,
    activeSymbol: currentSymbol,
    // ... other chart properties
  ),
)
```

## Configuration

### AutoIntervalZoomRange Parameters

- `granularity`: The time interval in milliseconds (e.g., 60000 for 1-minute candles)
- `minPixelsPerInterval`: Minimum pixels per interval before switching to smaller granularity
- `maxPixelsPerInterval`: Maximum pixels per interval before switching to larger granularity  
- `optimalPixelsPerInterval`: Optimal pixels per interval for this granularity (default: 40.0)

### Pre-defined Ranges

You can use the default auto-interval ranges:

```dart
import 'package:deriv_chart/deriv_chart.dart';

// Uses the default trading timeframes configuration
zoomRanges: defaultAutoIntervalRanges,
```

The default ranges include common trading timeframes from 1 minute to 1 day.

## Integration with State Management

```dart
class ChartWidget extends StatefulWidget {
  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  int currentGranularity = 300000; // 5 minutes
  List<Tick> chartData = [];
  bool autoIntervalEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    Widget chartContent = DerivChart(
      mainSeries: DataSeries(chartData),
      granularity: currentGranularity,
      activeSymbol: 'EURUSD',
      // ... other properties
    );
    
    // Conditionally wrap with auto-interval if enabled
    if (autoIntervalEnabled) {
      chartContent = AutoIntervalWrapper(
        enabled: true,
        granularity: currentGranularity,
        onGranularityChangeRequested: _handleGranularityChange,
        child: chartContent,
      );
    }
    
    return chartContent;
  }
  
  void _handleGranularityChange(int suggestedGranularity) {
    final int suggestedSeconds = suggestedGranularity ~/ 1000;
    
    if (suggestedSeconds != currentGranularity ~/ 1000) {
      setState(() {
        currentGranularity = suggestedGranularity;
      });
      
      // Fetch new data with the suggested granularity
      _fetchChartData(suggestedSeconds);
    }
  }
  
  Future<void> _fetchChartData(int granularitySeconds) async {
    // Your data fetching logic here
    final newData = await fetchTickData(granularitySeconds);
    setState(() {
      chartData = newData;
    });
  }
}
```

## Benefits

1. **Ultra Simple**: Single wrapper widget with all logic built-in
2. **No Dependencies**: No manager classes or complex setup
3. **Consistent Pattern**: Follows the same pattern as other chart wrappers
4. **Minimal Code**: Fewer files and simpler architecture
5. **Easy Integration**: Works with both `Chart` and `DerivChart` widgets
6. **Better Performance**: Direct calculations without extra abstraction layers

## Architecture

### Simplified Design
```
AutoIntervalWrapper (all-in-one)
├── ZoomLevelObserver implementation
├── Granularity calculation logic
├── State management (current/last suggested)
└── Provider<ZoomLevelObserver> for children
```

### What's Inside AutoIntervalWrapper
- **State Tracking**: Current granularity and last suggestion
- **Calculation Logic**: Optimal granularity based on zoom ranges
- **Observer Interface**: Implements `ZoomLevelObserver` directly
- **Provider Integration**: Exposes itself to chart components

## Migration from Old Approach

If you were using the old `ChartAxisConfig.autoIntervalEnabled` approach:

### Before (Old Way)
```dart
Chart(
  // ... properties
  chartAxisConfig: ChartAxisConfig(
    autoIntervalEnabled: true,
    autoIntervalZoomRanges: yourRanges,
  ),
  onGranularityChangeRequested: handleChange,
)
```

### After (New Simplified Way)
```dart
AutoIntervalWrapper(
  enabled: true,
  granularity: currentGranularity,
  zoomRanges: yourRanges,
  onGranularityChangeRequested: handleChange,
  child: Chart(
    // ... properties
    chartAxisConfig: ChartAxisConfig(
      // autoIntervalEnabled no longer needed
    ),
  ),
)
```

## Technical Notes

- **No AutoIntervalManager**: All logic is directly in the wrapper state
- **Stateful Widget**: Manages granularity state and calculations internally  
- **Provider Pattern**: Exposes `ZoomLevelObserver` interface to children
- **Automatic Cleanup**: No manual disposal needed - Flutter handles it
- **Reactive Updates**: Responds to granularity changes via `didUpdateWidget`

The wrapper approach provides maximum simplicity with minimal overhead!
