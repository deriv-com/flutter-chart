import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Screen that displays a candle chart with a bottom indicator.
class CandleChartWithIndicatorScreen extends BaseChartScreen {
  /// Initialize the candle chart with indicator screen.
  const CandleChartWithIndicatorScreen({Key? key}) : super(key: key);

  @override
  State<CandleChartWithIndicatorScreen> createState() =>
      _CandleChartWithIndicatorScreenState();
}

class _CandleChartWithIndicatorScreenState
    extends BaseChartScreenState<CandleChartWithIndicatorScreen> {
  Color _positiveColor = Colors.green;
  Color _negativeColor = Colors.red;
  bool _showRSI = true;
  int _rsiPeriod = 14;

  // Create an indicators repository to manage indicators
  late final Repository<IndicatorConfig> _indicatorsRepo;

  @override
  void initState() {
    super.initState();
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'candle_chart_with_indicator',
    );

    // Add initial indicators
    _updateIndicators();
  }

  void _updateIndicators() {
    // Clear existing indicators
    _indicatorsRepo.clear();

    // Add RSI if enabled
    if (_showRSI) {
      _indicatorsRepo.add(
        RSIIndicatorConfig(
          period: _rsiPeriod,
          lineStyle: const LineStyle(
            color: Colors.blue,
          ),
          oscillatorLinesConfig: const OscillatorLinesConfig(
            overboughtValue: 70,
            oversoldValue: 30,
            overboughtStyle: LineStyle(color: Colors.red),
            oversoldStyle: LineStyle(color: Colors.green),
          ),
        ),
      );
    }
  }

  @override
  String getTitle() => 'Candle Chart with Bottom Indicator';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('candle_chart_with_indicator'),
      mainSeries: CandleSeries(
        candles,
        style: CandleStyle(
          positiveColor: _positiveColor,
          negativeColor: _negativeColor,
        ),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      activeSymbol: 'CANDLE_CHART_WITH_INDICATOR',
      indicatorsRepo: _indicatorsRepo, // Pass the indicators repository
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // RSI Indicator controls
          Row(
            children: [
              const Text('RSI Indicator:'),
              const SizedBox(width: 8),
              Switch(
                value: _showRSI,
                onChanged: (value) {
                  setState(() {
                    _showRSI = value;
                    _updateIndicators();
                  });
                },
              ),
              const SizedBox(width: 16),
              const Text('Period:'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _rsiPeriod.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 25,
                  label: _rsiPeriod.toString(),
                  onChanged: (value) {
                    setState(() {
                      _rsiPeriod = value.toInt();
                      _updateIndicators();
                    });
                  },
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(_rsiPeriod.toString(), textAlign: TextAlign.center),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Candle chart controls
          _buildColorRow(
            label: 'Positive Color:',
            colors: [Colors.green, Colors.blue, Colors.purple, Colors.teal],
            isPositive: true,
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            label: 'Negative Color:',
            colors: [Colors.red, Colors.orange, Colors.pink, Colors.brown],
            isPositive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow({
    required String label,
    required List<Color> colors,
    required bool isPositive,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120, // Fixed width for labels to ensure alignment
          child: Text(label),
        ),
        ...colors
            .map((color) => _buildColorButton(color, isPositive: isPositive)),
      ],
    );
  }

  Widget _buildColorButton(Color color, {required bool isPositive}) {
    final currentColor = isPositive ? _positiveColor : _negativeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isPositive) {
              _positiveColor = color;
            } else {
              _negativeColor = color;
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
