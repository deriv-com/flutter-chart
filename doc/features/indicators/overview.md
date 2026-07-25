# Technical Indicators Overview

This document provides an overview of the technical indicators available in the Deriv Chart library, explaining their purpose, categories, and how to use them.

## Introduction to Technical Indicators

Technical indicators are mathematical calculations based on price, volume, or open interest of a security or contract. They are used to forecast price direction and to generate trading signals. The Deriv Chart library provides a comprehensive set of technical indicators to help traders analyze market data and make informed decisions.

## Indicator Categories

The Deriv Chart library organizes indicators into several categories:

### Moving Averages

Moving averages smooth out price data to create a single flowing line, making it easier to identify trends. They are the building blocks for many other technical indicators.

Available moving averages:
- Simple Moving Average (SMA)
- Exponential Moving Average (EMA)
- Double Exponential Moving Average (DEMA)
- Triple Exponential Moving Average (TEMA)
- Triangular Moving Average (TRIMA)
- Weighted Moving Average (WMA)
- Modified Moving Average (MMA)
- Least Squares Moving Average (LSMA)
- Hull Moving Average (HMA)
- Variable Moving Average (VMA)
- Welles Wilder Smoothing Moving Average (WWSMA)
- Zero-Lag Exponential Moving Average (ZELMA)

[Learn more about Moving Averages](moving_averages.md)

### Oscillators

Oscillators are indicators that fluctuate above and below a centerline or between upper and lower bounds. They help identify overbought or oversold conditions and potential trend reversals.

Available oscillators:
- Relative Strength Index (RSI)
- Stochastic Momentum Index (SMI)
- Moving Average Convergence Divergence (MACD)
- Awesome Oscillator
- Williams %R
- Rate of Change (ROC)
- Chande Momentum Oscillator (CMO)
- Gator Oscillator

[Learn more about Oscillators](oscillators.md)

### Trend Indicators

Trend indicators help identify the direction of the market trend and potential changes in that direction.

Available trend indicators:
- Average Directional Index (ADX)
- Parabolic SAR
- Ichimoku Cloud

[Learn more about Trend Indicators](trend_indicators.md)

### Volatility Indicators

Volatility indicators measure the rate of price movement, regardless of direction. They help traders identify potential breakouts or periods of consolidation.

Available volatility indicators:
- Bollinger Bands
- Average True Range (ATR)
- Standard Deviation
- Variance

[Learn more about Volatility Indicators](volatility.md)

### Channel Indicators

Channel indicators create bands that contain price movement, helping traders identify potential support and resistance levels.

Available channel indicators:
- Donchian Channel
- Moving Average Envelope
- Fixed Channel Bands (FCB)

## Using Indicators in the Chart

The Deriv Chart library provides two ways to add indicators to your charts:

1. **Overlay Indicators**: These indicators share the same Y-axis as the main chart and are drawn on top of it.
2. **Bottom Indicators**: These indicators have their own Y-axis and are drawn below the main chart.

### Adding Indicators

You can add indicators to your chart using the `overlayConfigs` and `bottomConfigs` parameters:

```dart
Chart(
  mainSeries: CandleSeries(candles),
  // Overlay indicators (on the main chart)
  overlayConfigs: [
    // Bollinger Bands
    BollingerBandsIndicatorConfig(
      period: 20,
      standardDeviation: 2,
      movingAverageType: MovingAverageType.exponential,
      upperLineStyle: LineStyle(color: Colors.purple),
      middleLineStyle: LineStyle(color: Colors.black),
      lowerLineStyle: LineStyle(color: Colors.blue),
    ),
    // Simple Moving Average
    MAIndicatorConfig(
      period: 14,
      type: MovingAverageType.simple,
      lineStyle: LineStyle(color: Colors.red),
    ),
  ],
  // Bottom indicators (separate charts)
  bottomConfigs: [
    // Relative Strength Index
    RSIIndicatorConfig(
      period: 14,
      lineStyle: LineStyle(color: Colors.green),
      oscillatorLinesConfig: OscillatorLinesConfig(
        overboughtValue: 70,
        oversoldValue: 30,
      ),
      showZones: true,
    ),
    // Moving Average Convergence Divergence
    MACDIndicatorConfig(
      fastPeriod: 12,
      slowPeriod: 26,
      signalPeriod: 9,
      lineStyle: LineStyle(color: Colors.blue),
      signalLineStyle: LineStyle(color: Colors.red),
      histogramStyle: HistogramStyle(
        positiveColor: Colors.green,
        negativeColor: Colors.red,
      ),
    ),
  ],
  pipSize: 2,
)
```

### Using DerivChart for Indicator Management

The `DerivChart` widget provides a more user-friendly way to manage indicators:

```dart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60,
  activeSymbol: 'R_100',
  pipSize: 2,
)
```

This widget includes UI controls for adding, removing, and configuring indicators. It also saves indicator settings to persistent storage.

### Creating a Custom Indicator Repository

For more control over indicator management, you can create your own `AddOnsRepository`:

```dart
final indicatorsRepo = AddOnsRepository<IndicatorConfig>(
  createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
  onEditCallback: (int index) {
    // Handle editing of indicator at index
  },
  sharedPrefKey: 'R_100',
);

// Load saved indicators
await indicatorsRepo.loadFromPrefs(
  await SharedPreferences.getInstance(),
  'R_100',
);

// Add an indicator
indicatorsRepo.add(RSIIndicatorConfig(period: 14));

// Remove an indicator
indicatorsRepo.removeAt(0);

// Update an indicator
indicatorsRepo.updateAt(0, RSIIndicatorConfig(period: 21));

// Use the repository with DerivChart
DerivChart(
  mainSeries: CandleSeries(candles),
  indicatorsRepo: indicatorsRepo,
  granularity: 60,
  pipSize: 2,
)
```

## Indicator Configuration

Each indicator has its own configuration class that extends `IndicatorConfig`. These classes provide parameters to customize the indicator's behavior and appearance.

### Common Configuration Parameters

Most indicators share these common parameters:

- **period**: The number of data points used in the calculation
- **lineStyle**: The style of the indicator line (color, thickness, etc.)
- **offset**: The number of periods to shift the indicator (positive for right, negative for left)

### Example: RSI Configuration

```dart
RSIIndicatorConfig(
  period: 14,
  lineStyle: LineStyle(
    color: Colors.green,
    thickness: 1,
  ),
  oscillatorLinesConfig: OscillatorLinesConfig(
    overboughtValue: 70,
    oversoldValue: 30,
    overboughtStyle: LineStyle(color: Colors.red),
    oversoldStyle: LineStyle(color: Colors.green),
  ),
  showZones: true,
)
```

### Example: Bollinger Bands Configuration

```dart
BollingerBandsIndicatorConfig(
  period: 20,
  standardDeviation: 2,
  movingAverageType: MovingAverageType.exponential,
  upperLineStyle: LineStyle(color: Colors.purple),
  middleLineStyle: LineStyle(color: Colors.black),
  lowerLineStyle: LineStyle(color: Colors.blue),
)
```

## Creating Custom Indicators

You can create custom indicators by extending the appropriate base classes:

1. Create a configuration class that extends `IndicatorConfig`
2. Create a series class that extends `AbstractSingleIndicatorSeries` or `Series`
3. Create a painter class that extends `DataPainter`

Example of a custom indicator:

```dart
// Configuration
class CustomIndicatorConfig extends IndicatorConfig {
  final int period;
  final LineStyle lineStyle;
  
  CustomIndicatorConfig({
    required this.period,
    this.lineStyle = const LineStyle(),
    super.id,
  });
  
  @override
  String get name => 'Custom ($period)';
  
  @override
  bool get isOverlay => true;
  
  @override
  Series createSeries(List<Candle> candles) => CustomIndicatorSeries(
    candles,
    period: period,
    lineStyle: lineStyle,
  );
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'Custom',
    'period': period,
    'lineStyle': lineStyle.toJson(),
  };
  
  factory CustomIndicatorConfig.fromJson(Map<String, dynamic> json) => CustomIndicatorConfig(
    id: json['id'],
    period: json['period'],
    lineStyle: LineStyle.fromJson(json['lineStyle']),
  );
}

// Series
class CustomIndicatorSeries extends AbstractSingleIndicatorSeries {
  final int period;
  final LineStyle lineStyle;
  
  CustomIndicatorSeries(
    List<Candle> candles, {
    required this.period,
    required this.lineStyle,
  }) : super(candles);
  
  @override
  List<Tick> _calculateIndicatorValues() {
    final result = <Tick>[];
    
    // Custom calculation logic
    for (int i = period - 1; i < candles.length; i++) {
      double sum = 0;
      for (int j = 0; j < period; j++) {
        sum += candles[i - j].close;
      }
      final value = sum / period;
      
      result.add(Tick(
        epoch: candles[i].epoch,
        quote: value,
      ));
    }
    
    return result;
  }
  
  @override
  SeriesPainter createPainter() => CustomIndicatorPainter(this);
}

// Painter
class CustomIndicatorPainter extends DataPainter<Tick> {
  final CustomIndicatorSeries series;
  
  CustomIndicatorPainter(this.series) : super(series);
  
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
      ..color = series.lineStyle.color
      ..strokeWidth = series.lineStyle.thickness
      ..style = PaintingStyle.stroke;
    
    path.moveTo(
      xFromEpoch(data.first.epoch),
      yFromQuote(data.first.quote),
    );
    
    for (int i = 1; i < data.length; i++) {
      path.lineTo(
        xFromEpoch(data[i].epoch),
        yFromQuote(data[i].quote),
      );
    }
    
    canvas.drawPath(path, paint);
  }
}
```

## Next Steps

Now that you understand the technical indicators available in the Deriv Chart library, you can explore:

- [Moving Averages](moving_averages.md) - Learn about moving average indicators
- [Oscillators](oscillators.md) - Learn about oscillator indicators
- [Volatility Indicators](volatility.md) - Learn about volatility indicators
- [Custom Indicators](custom_indicators.md) - Learn how to create custom indicators