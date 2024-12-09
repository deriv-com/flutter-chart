# Technical Indicators

Flutter Chart provides a comprehensive set of technical indicators to enhance your market analysis. Our library supports a wide range of indicators for different types of analysis.

## Available Indicators

### Trend Indicators
- Bollinger Bands
- Donchian Channels
- Moving Averages (MA)
- Moving Average Envelope (MAE)
- Moving Average Rainbow
- MACD (Moving Average Convergence Divergence)
- Ichimoku Cloud
- ZigZag

### Momentum Indicators
- Awesome Oscillator
- CCI (Commodity Channel Index)
- RSI (Relative Strength Index)
- ROC (Rate of Change)
- Stochastic Oscillator
- Williams %R
- DPO (Detrended Price Oscillator)
- SMI (Stochastic Momentum Index)

### Volatility Indicators
- Aroon
- ADX (Average Directional Index)
- Alligator
- Gator Oscillator
- FCB (Fractal Chaos Bands)

And many more! Our indicator system is designed to be extensible, allowing you to add custom indicators as needed.

## Using Indicators

Here's an example of how to add an indicator to your chart:

```dart
// Example of adding Bollinger Bands
BollingerBandsSeries(
  data: yourData,
  period: 20,
  standardDeviation: 2,
)

// Example of adding RSI
RSISeries(
  data: yourData,
  period: 14,
)
```

## Custom Indicators

You can also create your own custom indicators by extending our indicator base classes. This allows you to implement any technical indicator that suits your trading strategy.
