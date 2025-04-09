import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../../widgets/color_picker_widget.dart';
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
            DerivColorPicker(
              label: 'Positive Color:',
              selectedColor: _positiveColor,
              onColorChanged: (color) {
                setState(() {
                  _positiveColor = color;
                });
              },
              presetColors: const [
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.teal,
                Colors.lightGreen,
                Colors.cyan
              ],
            ),
            const SizedBox(height: 12),
            DerivColorPicker(
              label: 'Negative Color:',
              selectedColor: _negativeColor,
              onColorChanged: (color) {
                setState(() {
                  _negativeColor = color;
                });
              },
              presetColors: const [
                Colors.red,
                Colors.orange,
                Colors.pink,
                Colors.brown,
                Colors.deepOrange,
                Colors.redAccent
              ],
            ),
          ],
        ),
      ),
    );
  }
}
