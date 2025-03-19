import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Screen that displays an OHLC chart with an indicator.
class OHLCChartWithIndicatorScreen extends BaseChartScreen {
  /// Initialize the OHLC chart with indicator screen.
  const OHLCChartWithIndicatorScreen({Key? key}) : super(key: key);

  @override
  State<OHLCChartWithIndicatorScreen> createState() => _OHLCChartWithIndicatorScreenState();
}

class _OHLCChartWithIndicatorScreenState extends BaseChartScreenState<OHLCChartWithIndicatorScreen> {
  Color _positiveColor = Colors.green;
  Color _negativeColor = Colors.red;
  bool _showBollingerBands = true;
  int _bollingerPeriod = 20;
  double _bollingerDeviation = 2;
  final MovingAverageType _bollingerMAType = MovingAverageType.simple;
  
  // Create an indicators repository to manage indicators
  late final Repository<IndicatorConfig> _indicatorsRepo;
  
  @override
  void initState() {
    super.initState();
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'ohlc_chart_with_indicator',
    );
    
    // Add initial indicators
    _updateIndicators();
  }
  
  void _updateIndicators() {
    // Clear existing indicators
    _indicatorsRepo.clear();
    
    // Add Bollinger Bands if enabled
    if (_showBollingerBands) {
      _indicatorsRepo.add(
        BollingerBandsIndicatorConfig(
          period: _bollingerPeriod,
          standardDeviation: _bollingerDeviation,
          movingAverageType: _bollingerMAType,
          upperLineStyle: const LineStyle(color: Colors.purple),
          middleLineStyle: const LineStyle(color: Colors.blue),
          lowerLineStyle: const LineStyle(color: Colors.purple),
        ),
      );
    }
  }

  @override
  String getTitle() => 'OHLC Chart with Indicator';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('ohlc_chart_with_indicator'),
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
      activeSymbol: 'OHLC_CHART_WITH_INDICATOR',
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
          // Bollinger Bands Indicator controls
          Row(
            children: [
              const Text('Bollinger Bands:'),
              const SizedBox(width: 8),
              Switch(
                value: _showBollingerBands,
                onChanged: (value) {
                  setState(() {
                    _showBollingerBands = value;
                    _updateIndicators();
                  });
                },
              ),
            ],
          ),
          if (_showBollingerBands) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Period:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _bollingerPeriod.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 45,
                      label: _bollingerPeriod.toString(),
                      onChanged: (value) {
                        setState(() {
                          _bollingerPeriod = value.toInt();
                          _updateIndicators();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(_bollingerPeriod.toString(),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Deviation:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _bollingerDeviation,
                      min: 1,
                      max: 4,
                      divisions: 6,
                      label: _bollingerDeviation.toString(),
                      onChanged: (value) {
                        setState(() {
                          _bollingerDeviation = value;
                          _updateIndicators();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(_bollingerDeviation.toString(),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // OHLC chart controls
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
