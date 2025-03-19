import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

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
  Color _positiveColor = Colors.green;
  Color _negativeColor = Colors.red;
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
          positiveColor: _positiveColor,
          negativeColor: _negativeColor,
        ),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      activeSymbol: 'HOLLOW_CANDLE_WITH_INDICATOR',
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
