import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:showcase_app/screens/chart_examples/base_chart_screen.dart';

/// Screen that displays a chart with indicators.
class IndicatorsScreen extends BaseChartScreen {
  /// Initialize the indicators screen.
  const IndicatorsScreen({Key? key}) : super(key: key);

  @override
  State<IndicatorsScreen> createState() => _IndicatorsScreenState();
}

class _IndicatorsScreenState extends BaseChartScreenState<IndicatorsScreen> {
  bool _showBollingerBands = true;
  bool _showRSI = true;
  bool _showMACD = false;
  
  int _bollingerPeriod = 20;
  double _bollingerDeviation = 2.0;
  MovingAverageType _bollingerMAType = MovingAverageType.simple;
  
  int _rsiPeriod = 14;
  
  // Create an indicators repository to manage indicators
  late final Repository<IndicatorConfig> _indicatorsRepo;
  
  @override
  void initState() {
    super.initState();
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      sharedPrefKey: 'indicators_screen',
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
    
    // Add RSI if enabled
    if (_showRSI) {
      _indicatorsRepo.add(
        RSIIndicatorConfig(
          period: _rsiPeriod,
          lineStyle: const LineStyle(
            color: Colors.blue,
            thickness: 1,
          ),
          oscillatorLinesConfig: const OscillatorLinesConfig(
            overboughtValue: 70,
            oversoldValue: 30,
            overboughtStyle: LineStyle(color: Colors.red),
            oversoldStyle: LineStyle(color: Colors.green),
          ),
          showZones: true,
        ),
      );
    }
    
    // Add MACD if enabled
    if (_showMACD) {
      _indicatorsRepo.add(
        MACDIndicatorConfig(
          lineStyle: const LineStyle(color: Colors.blue),
          signalLineStyle: const LineStyle(color: Colors.red),
        ),
      );
    }
  }
  
  @override
  String getTitle() => 'Chart with Indicators';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('indicators_chart'),
      mainSeries: CandleSeries(candles),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      indicatorsRepo: _indicatorsRepo, // Pass the indicators repository
      activeSymbol: 'INDICATORS_CHART',
    );
  }
  
  Widget _buildIndicatorToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First row: BB and RSI toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildIndicatorToggle('Bollinger Bands:', _showBollingerBands, (value) {
                    setState(() {
                      _showBollingerBands = value;
                      _updateIndicators();
                    });
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildIndicatorToggle('RSI:', _showRSI, (value) {
                    setState(() {
                      _showRSI = value;
                      _updateIndicators();
                    });
                  }),
                ),
              ),
            ],
          ),
          
          // Second row: MACD toggle centered
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildIndicatorToggle('MACD:', _showMACD, (value) {
              setState(() {
                _showMACD = value;
                _updateIndicators();
              });
            }),
          ),
          if (_showBollingerBands) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('BB Period:'),
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
                    child: Text(_bollingerPeriod.toString(), textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('BB Deviation:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _bollingerDeviation,
                      min: 1.0,
                      max: 4.0,
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
                    child: Text(_bollingerDeviation.toString(), textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ],
          if (_showRSI) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('RSI Period:'),
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
            ),
          ],
        ],
      ),
    );
  }
}
