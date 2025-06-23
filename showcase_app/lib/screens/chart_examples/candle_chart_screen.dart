import 'package:flutter/foundation.dart';
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
  Color _bullishBodyColor = CandleBullishThemeColors.candleBullishBodyDefault;
  Color _bearishBodyColor = CandleBearishThemeColors.candleBearishBodyDefault;
  Color _bullishWickColor = CandleBullishThemeColors.candleBullishWickDefault;
  Color _bearishWickColor = CandleBearishThemeColors.candleBearishWickDefault;
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

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
          candleBullishBodyColor: _bullishBodyColor,
          candleBearishBodyColor: _bearishBodyColor,
          candleBullishWickColor: _bullishWickColor,
          candleBearishWickColor: _bearishWickColor,
        ),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      activeSymbol: 'CANDLE_CHART',
      // Explicitly set an empty indicators repository to remove any default indicators
      indicatorsRepo: _emptyIndicatorsRepo,
      showCrosshair: _showCrosshair,
      crosshairVariant: _useLargeScreenCrosshair
          ? CrosshairVariant.largeScreen
          : CrosshairVariant.smallScreen,
      theme: _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      useDrawingToolsV2: _useDrawingToolsV2,
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
            DerivColorPicker(
              label: 'Bullish Body:',
              selectedColor: _bullishBodyColor,
              onColorChanged: (color) {
                setState(() {
                  _bullishBodyColor = color;
                });
              },
              presetColors: const [
                CandleBullishThemeColors.candleBullishBodyDefault,
                CandleBullishThemeColors.candleBullishBodyActive,
                Colors.green,
                Colors.blue,
                Colors.teal,
                Colors.cyan
              ],
            ),
            const SizedBox(height: 12),
            DerivColorPicker(
              label: 'Bearish Body:',
              selectedColor: _bearishBodyColor,
              onColorChanged: (color) {
                setState(() {
                  _bearishBodyColor = color;
                });
              },
              presetColors: const [
                CandleBearishThemeColors.candleBearishBodyDefault,
                CandleBearishThemeColors.candleBearishBodyActive,
                Colors.red,
                Colors.orange,
                Colors.pink,
                Colors.brown
              ],
            ),
            const SizedBox(height: 20),
            DerivColorPicker(
              label: 'Bullish Wick:',
              selectedColor: _bullishWickColor,
              onColorChanged: (color) {
                setState(() {
                  _bullishWickColor = color;
                });
              },
              presetColors: const [
                CandleBullishThemeColors.candleBullishWickDefault,
                CandleBullishThemeColors.candleBullishWickActive,
                Colors.green,
                Colors.blue,
                Colors.teal,
                Colors.cyan
              ],
            ),
            const SizedBox(height: 12),
            DerivColorPicker(
              label: 'Bearish Wick:',
              selectedColor: _bearishWickColor,
              onColorChanged: (color) {
                setState(() {
                  _bearishWickColor = color;
                });
              },
              presetColors: const [
                CandleBearishThemeColors.candleBearishWickDefault,
                CandleBearishThemeColors.candleBearishWickActive,
                Colors.red,
                Colors.orange,
                Colors.pink,
                Colors.brown
              ],
            ),
          ],
        ),
      ),
    );
  }
}
