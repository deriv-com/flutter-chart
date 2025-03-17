import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:showcase_app/screens/chart_examples/base_chart_screen.dart';

/// Screen that displays an OHLC chart example.
class OHLCChartScreen extends BaseChartScreen {
  /// Initialize the OHLC chart screen.
  const OHLCChartScreen({Key? key}) : super(key: key);

  @override
  State<OHLCChartScreen> createState() => _OHLCChartScreenState();
}

class _OHLCChartScreenState extends BaseChartScreenState<OHLCChartScreen> {
  Color _positiveColor = Colors.green;
  Color _negativeColor = Colors.red;

  @override
  String getTitle() => 'OHLC Chart';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('ohlc_chart'),
      mainSeries: OhlcCandleSeries(
        candles,
        style: CandleStyle(
          positiveColor: _positiveColor,
          negativeColor: _negativeColor,
        ),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      activeSymbol: 'OHLC_CHART',
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Positive Color:'),
              const SizedBox(width: 8),
              _buildColorButton(Colors.green, isPositive: true),
              _buildColorButton(Colors.blue, isPositive: true),
              _buildColorButton(Colors.purple, isPositive: true),
              _buildColorButton(Colors.teal, isPositive: true),
              const SizedBox(width: 16),
              const Text('Negative Color:'),
              const SizedBox(width: 8),
              _buildColorButton(Colors.red, isPositive: false),
              _buildColorButton(Colors.orange, isPositive: false),
              _buildColorButton(Colors.pink, isPositive: false),
              _buildColorButton(Colors.brown, isPositive: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color, {required bool isPositive}) {
    final currentColor = isPositive ? _positiveColor : _negativeColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
