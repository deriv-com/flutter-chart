import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Enum to identify which color is being modified
enum ColorType {
  /// Color for the body of bullish candles
  bullishBody,

  /// Color for the body of bearish candles
  bearishBody,

  /// Color for the wick of bullish candles
  bullishWick,

  /// Color for the wick of bearish candles
  bearishWick
}

/// Screen that displays a hollow candle chart with an indicator.
class HollowCandleWithIndicatorScreen extends BaseChartScreen {
  /// Initialize the hollow candle chart with indicator screen.
  const HollowCandleWithIndicatorScreen({Key? key}) : super(key: key);

  @override
  State<HollowCandleWithIndicatorScreen> createState() =>
      _HollowCandleWithIndicatorScreenState();
}

class _HollowCandleWithIndicatorScreenState
    extends BaseChartScreenState<HollowCandleWithIndicatorScreen> {
  Color _bullishBodyColor = CandleBullishThemeColors.candleBullishBodyDefault;
  Color _bearishBodyColor = CandleBearishThemeColors.candleBearishBodyDefault;
  Color _bullishWickColor = CandleBullishThemeColors.candleBullishWickDefault;
  Color _bearishWickColor = CandleBearishThemeColors.candleBearishWickDefault;
  bool _showMACD = true;

  // Create an indicators repository to manage indicators
  late final Repository<IndicatorConfig> _indicatorsRepo;

  @override
  void initState() {
    super.initState();
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'hollow_candle_with_indicator',
    );

    // Add initial indicators
    _updateIndicators();
  }

  void _updateIndicators() {
    // Clear existing indicators
    _indicatorsRepo.clear();

    // Add MACD if enabled
    if (_showMACD) {
      _indicatorsRepo.add(
        const MACDIndicatorConfig(
          lineStyle: LineStyle(color: Colors.blue),
          signalLineStyle: LineStyle(color: Colors.red),
        ),
      );
    }
  }

  @override
  String getTitle() => 'Hollow Candle Chart with Indicator';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('hollow_candle_with_indicator'),
      mainSeries: HollowCandleSeries(
        candles,
        style: CandleStyle(
          candleBullishBodyColor: _bullishBodyColor,
          candleBearishBodyColor: _bearishBodyColor,
          candleBullishWickColor: _bullishWickColor,
          candleBearishWickColor: _bearishWickColor,
        ),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      activeSymbol: 'HOLLOW_CANDLE_WITH_INDICATOR',
      indicatorsRepo: _indicatorsRepo, // Pass the indicators repository
      useDrawingToolsV2: true,
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MACD Indicator controls
          Row(
            children: [
              const Text('MACD Indicator:'),
              const SizedBox(width: 8),
              Switch(
                value: _showMACD,
                onChanged: (value) {
                  setState(() {
                    _showMACD = value;
                    _updateIndicators();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hollow Candle chart controls
          _buildColorRow(
            label: 'Bullish Body:',
            colors: [
              CandleBullishThemeColors.candleBullishBodyDefault,
              CandleBullishThemeColors.candleBullishBodyActive,
              Colors.green,
              Colors.blue,
            ],
            colorType: ColorType.bullishBody,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'Bearish Body:',
            colors: [
              CandleBearishThemeColors.candleBearishBodyDefault,
              CandleBearishThemeColors.candleBearishBodyActive,
              Colors.red,
              Colors.orange,
            ],
            colorType: ColorType.bearishBody,
          ),
          const SizedBox(height: 20),
          _buildColorRow(
            label: 'Bullish Wick:',
            colors: [
              CandleBullishThemeColors.candleBullishWickDefault,
              CandleBullishThemeColors.candleBullishWickActive,
              Colors.green,
              Colors.blue,
            ],
            colorType: ColorType.bullishWick,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'Bearish Wick:',
            colors: [
              CandleBearishThemeColors.candleBearishWickDefault,
              CandleBearishThemeColors.candleBearishWickActive,
              Colors.red,
              Colors.orange,
            ],
            colorType: ColorType.bearishWick,
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow({
    required String label,
    required List<Color> colors,
    required ColorType colorType,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120, // Fixed width for labels to ensure alignment
          child: Text(label),
        ),
        ...colors
            .map((color) => _buildColorButton(color, colorType: colorType)),
      ],
    );
  }

  Widget _buildColorButton(Color color, {required ColorType colorType}) {
    late Color currentColor;

    switch (colorType) {
      case ColorType.bullishBody:
        currentColor = _bullishBodyColor;
        break;
      case ColorType.bearishBody:
        currentColor = _bearishBodyColor;
        break;
      case ColorType.bullishWick:
        currentColor = _bullishWickColor;
        break;
      case ColorType.bearishWick:
        currentColor = _bearishWickColor;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            switch (colorType) {
              case ColorType.bullishBody:
                _bullishBodyColor = color;
                break;
              case ColorType.bearishBody:
                _bearishBodyColor = color;
                break;
              case ColorType.bullishWick:
                _bullishWickColor = color;
                break;
              case ColorType.bearishWick:
                _bearishWickColor = color;
                break;
            }
          });
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: currentColor == color ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
