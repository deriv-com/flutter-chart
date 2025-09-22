# Adaptive Interval (Auto-Interval) Feature

## Overview

The **adaptive interval** (also called **auto-interval**) feature automatically adjusts the chart's time granularity (interval) based on the current zoom level. This ensures that the chart remains readable and usable at all zoom levels, without requiring the user to manually select the most appropriate interval.

When enabled, the chart will suggest and can switch to the most suitable granularity as the user zooms in or out, based on a configurable mapping between zoom levels and time intervals.

---

## Key Components

- **`AutoIntervalWrapper`**: A widget that observes zoom level changes and manages the logic for suggesting granularity changes.
- **`ZoomLevelObserver`**: An interface for components that need to react to zoom level changes.
- **`AutoIntervalZoomRange`**: A configuration class that maps each granularity (in milliseconds) to its optimal pixel range on the chart.
- **`ChartAxisConfig`**: Holds the configuration for enabling/disabling auto-interval and its zoom ranges.

---

## How It Works

1. **Zoom Level Observation**: The chart's x-axis model notifies the `AutoIntervalWrapper` of zoom level changes (in milliseconds per pixel).
2. **Optimal Granularity Calculation**: The wrapper calculates the optimal granularity for the current zoom level using the configured `AutoIntervalZoomRange` list.
3. **Granularity Suggestion**: If a different granularity is optimal and hasn't already been suggested, the wrapper triggers the `onGranularityChangeRequested` callback.
4. **Granularity Update**: The parent widget or chart controller can then update the chart's granularity, which will fetch and display data at the new interval.

---

## Configuration

- **Enable/Disable**: Set `autoIntervalEnabled` in `ChartAxisConfig` to `true` or `false`.
- **Customize Ranges**: Modify `autoIntervalZoomRanges` in `ChartAxisConfig` to change which granularities are used at which zoom levels.
- **Default Ranges**: The default configuration covers common trading timeframes (1m, 2m, 5m, etc.), each with a pixel range for when it should be used.

Example:
```dart
ChartAxisConfig(
  autoIntervalEnabled: true,
  autoIntervalZoomRanges: [
    AutoIntervalZoomRange(
      granularity: 60000, // 1 minute
      minPixelsPerInterval: 12,
      maxPixelsPerInterval: 24,
    ),
    // ... more ranges ...
  ],
)
```

---

## Usage Example

Wrap your chart widget with `AutoIntervalWrapper`:

```dart
AutoIntervalWrapper(
  enabled: true,
  granularity: currentGranularity, // in milliseconds
  zoomRanges: autoIntervalRanges,  // List<AutoIntervalZoomRange>
  onGranularityChangeRequested: (newGranularity) {
    // Update chart granularity and fetch new data
  },
  child: ... // your chart widget
)
```

- The `onGranularityChangeRequested` callback is called when the wrapper suggests a new optimal granularity.
- You are responsible for updating the chart's granularity and fetching new data as needed.

---

## Internal Logic

- The wrapper listens for zoom level changes (ms per pixel) via the `ZoomLevelObserver` interface.
- For each zoom event, it calculates the number of pixels each interval (candle) would occupy at the current zoom.
- It checks all configured `AutoIntervalZoomRange` entries to find which range the current zoom fits into, and selects the one closest to its optimal pixel width.
- If the optimal granularity is different from the current one and hasn't already been suggested, it triggers the callback.

---

## Example Integration

```dart
ChartAxisConfig config = ChartAxisConfig(
  autoIntervalEnabled: true,
);

Chart(
  chartAxisConfig: config,
  granularity: granularity,
  onGranularityChangeRequested: (int suggestedGranularity) {
    // Convert ms to seconds for API call if needed
    final int seconds = suggestedGranularity ~/ 1000;
    if (seconds != granularity) {
      // Update granularity and fetch new data
      setState(() => granularity = seconds);
      fetchDataWithGranularity(seconds);
    }
  },
  // ... other chart params ...
)
```

---

## Notes

- The adaptive interval feature is especially useful for financial charts where users frequently zoom in and out to analyze data at different timeframes.
- You can fully customize the mapping between zoom levels and granularities to suit your application's needs.
- The feature is opt-in and can be toggled at runtime.

---

## Related Classes and Files
- `lib/src/deriv_chart/chart/auto_interval/auto_interval_wrapper.dart`
- `lib/src/deriv_chart/chart/auto_interval/zoom_level_observer.dart`
- `lib/src/models/chart_axis_config.dart`
- `lib/src/deriv_chart/chart/x_axis/x_axis_model.dart`
- Example usage: `example/lib/main.dart` 
