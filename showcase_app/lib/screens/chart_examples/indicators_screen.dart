import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

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
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

  int _bollingerPeriod = 20;
  double _bollingerDeviation = 2;
  final MovingAverageType _bollingerMAType = MovingAverageType.simple;

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
      showCrosshair: _showCrosshair,
      crosshairVariant: _useLargeScreenCrosshair
          ? CrosshairVariant.largeScreen
          : CrosshairVariant.smallScreen,
      theme: _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      useDrawingToolsV2: _useDrawingToolsV2,
    );
  }

  Widget _buildIndicatorToggle(
      String label, bool value, ValueChanged<bool> onChanged) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Theme toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Theme:'),
              const SizedBox(width: 8),
              const Text('Light'),
              Switch(
                value: _useDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _useDarkTheme = value;
                  });
                },
              ),
              const Text('Dark'),
            ],
          ),
          const SizedBox(height: 16),

          // Crosshair controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Show Crosshair:'),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showCrosshair,
                    onChanged: (value) {
                      setState(() {
                        _showCrosshair = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _useLargeScreenCrosshair = !_useLargeScreenCrosshair;
                  });
                },
                child: Text(
                  'Crosshair: ${_useLargeScreenCrosshair ? 'Large' : 'Small'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Drawing Tools V2 toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Drawing Tools V2:'),
              const SizedBox(width: 8),
              Switch(
                value: _useDrawingToolsV2,
                onChanged: (value) {
                  setState(() {
                    _useDrawingToolsV2 = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Use Wrap for flexible layout of indicator toggles
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildIndicatorToggle('Bollinger Bands:', _showBollingerBands,
                  (value) {
                setState(() {
                  _showBollingerBands = value;
                  _updateIndicators();
                });
              }),
              _buildIndicatorToggle('RSI:', _showRSI, (value) {
                setState(() {
                  _showRSI = value;
                  _updateIndicators();
                });
              }),
              _buildIndicatorToggle('MACD:', _showMACD, (value) {
                setState(() {
                  _showMACD = value;
                  _updateIndicators();
                });
              }),
            ],
          ),
          const SizedBox(height: 8),
          if (_showBollingerBands) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  const Text('BB Deviation:'),
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
          if (_showRSI) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    child: Text(_rsiPeriod.toString(),
                        textAlign: TextAlign.center),
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
