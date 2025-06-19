# Advanced Features

This guide covers advanced features of the Deriv Chart library, including technical indicators, markers, annotations, and drawing tools.

## Technical Indicators

The Deriv Chart library provides support for technical indicators that can be displayed either on the main chart (overlay) or in separate charts below the main chart.

### Adding Indicators to Chart Widget

You can directly add indicators to the `Chart` widget using the `overlayConfigs` and `bottomConfigs` parameters:

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

### Using DerivChart for Indicator Management

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

### Automatic Repository Management

If you don't provide repositories to `DerivChart`, it will:
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

### External Repository Management

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

Annotations allow you to add visual elements to the chart, such as horizontal and vertical barriers.

### Horizontal Barriers

Horizontal barriers mark specific price levels on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    HorizontalBarrier(
      125.0, // Price level
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
  ],
)
```

### Vertical Barriers

Vertical barriers mark specific time points on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    VerticalBarrier(
      ticks[2].epoch, // Time point
      title: 'Event',
      style: VerticalBarrierStyle(
        color: Colors.blue,
        isDashed: false,
        titleBackgroundColor: Colors.blue.withOpacity(0.8),
        textStyle: TextStyle(color: Colors.white),
        labelPosition: VerticalBarrierLabelPosition.auto,
      ),
    ),
  ],
)
```

### Tick Indicators

Tick indicators highlight specific data points on the chart:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
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

### Combined Barriers

You can also create barriers that have both horizontal and vertical components:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  annotations: <ChartAnnotation>[
    CombinedBarrier(
      ticks.last,
      title: 'Combined Barrier',
      horizontalBarrierStyle: HorizontalBarrierStyle(
        color: Colors.purple,
        isDashed: true,
      ),
    ),
  ],
)
```

## Markers

Markers allow you to highlight specific points on the chart with interactive elements.

### Basic Markers

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries([
    Marker.up(
      epoch: ticks[1].epoch, 
      quote: ticks[1].quote, 
      onTap: () {
        print('Up marker tapped');
      }
    ),
    Marker.down(
      epoch: ticks[3].epoch, 
      quote: ticks[3].quote, 
      onTap: () {
        print('Down marker tapped');
      }
    ),
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

### Entry and Exit Ticks

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

### Custom Marker Icons

You can customize the appearance of markers by providing a custom marker icon painter:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  markerSeries: MarkerSeries(
    markers,
    markerIconPainter: CustomMarkerIconPainter(),
  ),
)
```

## Drawing Tools

The Deriv Chart library supports interactive drawing tools that allow users to draw on the chart.

### Using Drawing Tools with DerivChart

The `DerivChart` widget provides built-in support for drawing tools:

```dart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  drawingToolsRepo: myDrawingToolsRepo, // Optional
)
```

### Managing Drawing Tools

Similar to indicators, drawing tools can be managed automatically by DerivChart or through an external repository:

```dart
// Create a repository for drawing tools
final drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
  createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
  sharedPrefKey: 'R_100',
);

// Add drawing tools to the repository
drawingToolsRepo.add(LineDrawingToolConfig(
  // Configuration options
));

// Use the repository with DerivChart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  drawingToolsRepo: drawingToolsRepo,
)
```

### Available Drawing Tools

The library includes several built-in drawing tools:

- Line
- Horizontal Line
- Vertical Line
- Trend Line
- Rectangle
- Channel
- Fibonacci Fan
- Ray

## Real-World Example

Here's a complete example showing how to use advanced features in a real application:

```dart
class AdvancedChartScreen extends StatefulWidget {
  @override
  _AdvancedChartScreenState createState() => _AdvancedChartScreenState();
}

class _AdvancedChartScreenState extends State<AdvancedChartScreen> {
  final List<Candle> candles = []; // Your data source
  final ChartController controller = ChartController();
  late AddOnsRepository<IndicatorConfig> indicatorsRepo;
  late AddOnsRepository<DrawingToolConfig> drawingToolsRepo;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize repositories
    indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'R_100',
    );
    
    drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
      sharedPrefKey: 'R_100',
    );
    
    // Add default indicators
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
    
    // Load chart data
    _fetchChartData();
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
      appBar: AppBar(title: Text('Advanced Chart')),
      body: candles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : DerivChart(
              mainSeries: CandleSeries(candles),
              granularity: 60000,
              activeSymbol: 'R_100',
              pipSize: 4,
              controller: controller,
              indicatorsRepo: indicatorsRepo,
              drawingToolsRepo: drawingToolsRepo,
              isLive: true,
              annotations: <ChartAnnotation>[
                HorizontalBarrier(
                  candles.map((c) => c.close).reduce(max) * 1.05,
                  title: 'Resistance',
                  style: HorizontalBarrierStyle(
                    color: Colors.red,
                    isDashed: true,
                  ),
                ),
                TickIndicator(
                  Tick(
                    epoch: candles.last.epoch,
                    quote: candles.last.close,
                  ),
                  style: HorizontalBarrierStyle(
                    labelShape: LabelShape.pentagon,
                    hasBlinkingDot: true,
                  ),
                ),
              ],
              markerSeries: MarkerSeries(
                [
                  Marker.up(
                    epoch: candles[5].epoch,
                    quote: candles[5].high,
                    onTap: () => print('Marker tapped'),
                  ),
                ],
                entryTick: Tick(
                  epoch: candles.first.epoch,
                  quote: candles.first.open,
                ),
                exitTick: Tick(
                  epoch: candles.last.epoch,
                  quote: candles.last.close,
                ),
              ),
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

## Next Steps

Now that you understand the advanced features of the Deriv Chart library, you can explore:

- [Indicators Reference](../features/indicators/reference.md) - Detailed information about all available indicators
- [Drawing Tools Reference](../features/drawing_tools/reference.md) - Detailed information about all available drawing tools
- [Custom Indicators](../advanced_usage/custom_indicators.md) - Learn how to create custom indicators