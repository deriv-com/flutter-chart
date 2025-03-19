import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Screen that displays a candle chart example.
class CandleChartScreen extends BaseChartScreen {
  /// Initialize the candle chart screen.
  const CandleChartScreen({Key? key}) : super(key: key);

  @override
  State<CandleChartScreen> createState() => _CandleChartScreenState();
}

class _CandleChartScreenState extends BaseChartScreenState<CandleChartScreen> {
  Color _positiveColor = Colors.green;
  Color _negativeColor = Colors.red;

  @override
  String getTitle() => 'Candle Chart';

  // Create an empty indicators repository to ensure no indicators are shown
  final Repository<IndicatorConfig> _emptyIndicatorsRepo =
      AddOnsRepository<IndicatorConfig>(
    createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
    sharedPrefKey: 'candle_chart_indicators',
  );

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('candle_chart'),
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
      activeSymbol: 'CANDLE_CHART',
      // Explicitly set an empty indicators repository to remove any default indicators
      indicatorsRepo: _emptyIndicatorsRepo,
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
