# Configuration Options

The Deriv Chart library provides numerous configuration options to customize the appearance and behavior of your charts. This guide explains the available options and how to use them.

## Chart Widget Configuration

The `Chart` widget accepts various parameters to customize its behavior and appearance:

### Basic Configuration

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  granularity: 60000, // 60000 milliseconds (1 minute)
  theme: ChartDefaultDarkTheme(),
  controller: ChartController(),
)
```

### Core Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mainSeries` | `Series` | The primary data series to display (required) |
| `pipSize` | `int` | Number of decimal places for price values (default: 2) |
| `granularity` | `int` | Time interval in milliseconds for candles or average ms difference between consecutive ticks (default: 60000) |
| `theme` | `ChartTheme` | Theme for the chart (default: based on app theme) |
| `controller` | `ChartController` | Controller for programmatic chart manipulation |

### Data Series Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `overlaySeries` | `List<Series>` | Additional series to display on the main chart |
| `bottomSeries` | `List<Series>` | Series to display in separate charts below the main chart |
| `markerSeries` | `MarkerSeries` | Markers to display on the chart |
| `overlayConfigs` | `List<IndicatorConfig>` | Technical indicators to display on the main chart |
| `bottomConfigs` | `List<IndicatorConfig>` | Technical indicators to display in separate charts below the main chart |

### Visual Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `annotations` | `List<ChartAnnotation>` | Annotations to display on the chart (barriers, etc.) |
| `showCrosshair` | `bool` | Whether to display crosshair on long press (default: true) |
| `showDataFitButton` | `bool` | Whether to display the data fit button (default: true) |
| `showScrollToLastTickButton` | `bool` | Whether to display scroll to last tick button (default: true) |
| `loadingAnimationColor` | `Color` | The color of the loading animation |
| `chartAxisConfig` | `ChartAxisConfig` | Configuration for chart axes including grid and labels |

### Callback Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onVisibleAreaChanged` | `Function(int leftEpoch, int rightEpoch)` | Called when the visible area changes due to scrolling or zooming |
| `onQuoteAreaChanged` | `Function(double minQuote, double maxQuote)` | Called when the visible quote area changes |
| `onCrosshairAppeared` | `VoidCallback` | Called when the crosshair appears |
| `onCrosshairDisappeared` | `VoidCallback` | Called when the crosshair disappears |
| `onCrosshairHover` | `OnCrosshairHoverCallback` | Called when the crosshair cursor is hovered/moved |

## PipSize

The `pipSize` parameter determines the number of decimal places displayed for price values on the Y-axis. For example:

- `pipSize: 2` displays prices as 123.45
- `pipSize: 3` displays prices as 123.456
- `pipSize: 0` displays prices as 123

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 3,
)
```

## Granularity

The `granularity` parameter specifies the time interval in milliseconds for candle charts. It affects how candles are grouped and displayed:

- `granularity: 60000` represents 1-minute candles
- `granularity: 300000` represents 5-minute candles
- `granularity: 3600000` represents 1-hour candles

```dart
Chart(
  mainSeries: CandleSeries(candles),
  pipSize: 2,
  granularity: 300000, // 5-minute candles (300000 milliseconds)
)
```

## Theme Customization

You can customize the appearance of the chart by providing a custom theme:

```dart
class CustomTheme extends ChartDefaultDarkTheme {
  @override
  GridStyle get gridStyle => GridStyle(
    gridLineColor: Colors.yellow,
    xLabelStyle: textStyle(
      textStyle: caption2,
      color: Colors.yellow,
      fontSize: 13,
    ),
  );
  
  @override
  CrosshairStyle get crosshairStyle => CrosshairStyle(
    lineColor: Colors.orange,
    labelBackgroundColor: Colors.orange.withOpacity(0.8),
    labelTextStyle: textStyle(
      textStyle: caption1,
      color: Colors.white,
    ),
  );
}

// Using the custom theme
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  theme: CustomTheme(),
)
```

## Chart Controller

The `ChartController` allows programmatic control of the chart:

```dart
final controller = ChartController();

// In your widget
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  controller: controller,
)

// Programmatically control the chart
controller.scrollToLastTick(); // Scroll to the most recent data
controller.scale(100); // Zoom the chart
controller.scroll(100); // Scroll by 100 pixels
```

### Available Controller Methods

| Method | Description |
|--------|-------------|
| `scrollToLastTick({bool animate = false})` | Scroll to the most recent data with optional animation |
| `scale(double scale)` | Set the zoom level |

## Using Indicators

The Deriv Chart library provides support for technical indicators that can be displayed either on the main chart (overlay) or in separate charts below the main chart. There are two ways to add indicators to your charts:

### 1. Direct Configuration with Chart Widget

You can directly pass indicator configurations to the `Chart` widget:

```dart
Chart(
  mainSeries: CandleSeries(candles),
  pipSize: 2,
  granularity: 60000,
  // Indicators displayed on the main chart
  overlayConfigs: <IndicatorConfig>[
    BollingerBandsIndicatorConfig(
      period: 20,
      deviation: 2,
      maType: MAType.sma,
    ),
  ],
  // Indicators displayed in separate charts below the main chart
  bottomConfigs: <IndicatorConfig>[
    RSIIndicatorConfig(
      period: 14,
      overbought: 70,
      oversold: 30,
    ),
    SMIIndicatorConfig(
      period: 14,
      signalPeriod: 3,
    ),
  ],
)
```

### 2. Using AddOnsRepository with DerivChart Widget

For more advanced usage, including saving indicator settings, you can use the `DerivChart` widget with an `AddOnsRepository`:

```dart
// Create a repository for indicators
final indicatorsRepo = AddOnsRepository<IndicatorConfig>(
  createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
  sharedPrefKey: 'R_100', // Use the symbol code for saving settings
);

// Add indicators to the repository
indicatorsRepo.add(BollingerBandsIndicatorConfig(
  period: 20,
  deviation: 2,
  maType: MAType.sma,
));

indicatorsRepo.add(RSIIndicatorConfig(
  period: 14,
  overbought: 70,
  oversold: 30,
));

// Use the repository with DerivChart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  indicatorsRepo: indicatorsRepo,
)
```

### Repository Management in DerivChart

The `DerivChart` widget provides flexible options for managing indicators and drawing tools:

#### Automatic Repository Management

If you don't provide repositories, `DerivChart` will:
- Automatically instantiate its own `indicatorsRepo` and `drawingToolsRepo`
- Display UI icons over the chart to open built-in dialogs for adding, editing, and removing indicators and drawing tools
- Handle saving and loading configurations using the `activeSymbol` as the storage key
- Manage all UI interactions internally

```dart
// DerivChart with automatic repository management
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  // No indicatorsRepo or drawingToolsRepo provided
)
```

#### External Repository Management

If you provide your own repositories, `DerivChart` will:
- Use the provided repositories instead of creating its own
- Not display the built-in UI icons, assuming you'll handle UI interactions externally
- Still apply the indicators and drawing tools from the repositories to the chart

```dart
// DerivChart with external repository management
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  indicatorsRepo: myIndicatorsRepo, // Externally managed repository
  drawingToolsRepo: myDrawingToolsRepo, // Externally managed repository
)
```

When using external repositories, you're responsible for:
- Initializing the repositories
- Adding, editing, and removing items from the repositories
- Providing your own UI for managing indicators and drawing tools if needed

### Real-World Example

Here's how indicators are used in a complete application, similar to the example app:

```dart
class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final List<Candle> candles = []; // Your data source
  final ChartController controller = ChartController();
  late AddOnsRepository<IndicatorConfig> indicatorsRepo;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize indicators repository
    indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'R_100',
    );
    
    // Load saved indicators or add default ones
    _loadIndicators();
    
    // Load chart data
    _fetchChartData();
  }
  
  void _loadIndicators() {
    // Add default indicators if none are saved
    if (indicatorsRepo.items.isEmpty) {
      indicatorsRepo.add(BollingerBandsIndicatorConfig(
        period: 20,
        deviation: 2,
        maType: MAType.sma,
      ));
      
      indicatorsRepo.add(RSIIndicatorConfig(
        period: 14,
        overbought: 70,
        oversold: 30,
      ));
    }
  }
  
  void _fetchChartData() {
    // Fetch your chart data here
    // When data is received, update the state
    setState(() {
      // Update candles with new data
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chart with Indicators')),
      body: candles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : DerivChart(
              mainSeries: CandleSeries(candles),
              granularity: 60000,
              activeSymbol: 'R_100',
              pipSize: 4,
              controller: controller,
              indicatorsRepo: indicatorsRepo,
              isLive: true,
              onVisibleAreaChanged: (leftEpoch, rightEpoch) {
                // Load more historical data if needed
                if (leftEpoch < candles.first.epoch) {
                  _loadMoreHistory();
                }
              },
            ),
    );
  }
  
  void _loadMoreHistory() {
    // Load more historical data
  }
}
```

The `DerivChart` widget automatically:
- Filters indicators into overlay and bottom indicators based on their `isOverlay` property
- Provides UI buttons for adding, editing, and removing indicators
- Saves indicator configurations to persistent storage
- Loads saved indicators when the chart is initialized

### Available Indicators

The library includes many built-in indicators such as:

| Indicator | Type | Description |
|-----------|------|-------------|
| Bollinger Bands | Overlay | Shows volatility and potential price levels |
| Moving Average | Overlay | Smooths price data to show trends |
| RSI | Bottom | Relative Strength Index measures momentum |
| MACD | Bottom | Moving Average Convergence Divergence |
| Stochastic Oscillator | Bottom | Compares closing price to price range |
| Awesome Oscillator | Bottom | Shows market momentum |

## Annotations

Annotations allow you to add visual elements to the chart, such as horizontal and vertical barriers:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    HorizontalBarrier(
      125.0,
      title: 'Resistance',
      style: HorizontalBarrierStyle(
        color: Colors.red,
        isDashed: true,
        titleBackgroundColor: Colors.red.withOpacity(0.8),
        textStyle: TextStyle(color: Colors.white),
        labelShape: LabelShape.rectangle,
        labelHeight: 24,
        labelPadding: 4,
      ),
      visibility: HorizontalBarrierVisibility.forceToStayOnRange,
    ),
    VerticalBarrier(
      ticks[2].epoch,
      title: 'Event',
      style: VerticalBarrierStyle(
        color: Colors.blue,
        isDashed: false,
        titleBackgroundColor: Colors.blue.withOpacity(0.8),
        textStyle: TextStyle(color: Colors.white),
        labelPosition: VerticalBarrierLabelPosition.auto,
      ),
    ),
    TickIndicator(
      ticks.last,
      style: HorizontalBarrierStyle(
        labelShape: LabelShape.pentagon,
      ),
      visibility: HorizontalBarrierVisibility.normal,
    ),
  ],
)
```

## Markers

Markers allow you to highlight specific points on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries([
    Marker.up(epoch: ticks[1].epoch, quote: ticks[1].quote, onTap: () {
      print('Up marker tapped');
    }),
    Marker.down(epoch: ticks[3].epoch, quote: ticks[3].quote, onTap: () {
      print('Down marker tapped');
    }),
  ]),
)
```

### Active Marker

You can also display an active marker that responds to user interactions:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [
      Marker.up(epoch: ticks[1].epoch, quote: ticks[1].quote, onTap: () {}),
      Marker.down(epoch: ticks[3].epoch, quote: ticks[3].quote, onTap: () {}),
    ],
    activeMarker: ActiveMarker(
      epoch: ticks[1].epoch,
      quote: ticks[1].quote,
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

## Entry and Exit Ticks

You can highlight entry and exit points on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    [],
    entryTick: Tick(epoch: ticks[0].epoch, quote: ticks[0].quote),
    exitTick: Tick(epoch: ticks.last.epoch, quote: ticks.last.quote),
  ),
)
```

## DerivChart Configuration

The `DerivChart` widget is a wrapper around the `Chart` widget that provides additional functionality for managing indicators and drawing tools:

```dart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000, // 60000 milliseconds (1 minute)
  activeSymbol: 'R_100',
  pipSize: 4,
  // All Chart parameters are also available here
)
```

### DerivChart Specific Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `activeSymbol` | `String` | Symbol code for saving indicator settings |
| `indicatorsRepo` | `AddOnsRepository<IndicatorConfig>` | Repository for managing indicators |
| `drawingToolsRepo` | `AddOnsRepository<DrawingToolConfig>` | Repository for managing drawing tools |

## Next Steps

Now that you understand the configuration options available in the Deriv Chart library, you can explore:

- [Indicators](../features/indicators/overview.md) - Add technical indicators to your charts
- [Drawing Tools](../features/drawing_tools/overview.md) - Enable interactive drawing tools
- [Advanced Usage](../advanced_usage/custom_themes.md) - Learn about advanced customization options