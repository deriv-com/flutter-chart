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

/// Screen that displays an OHLC chart example.
class OHLCChartScreen extends BaseChartScreen {
  /// Initialize the OHLC chart screen.
  const OHLCChartScreen({Key? key}) : super(key: key);

  @override
  State<OHLCChartScreen> createState() => _OHLCChartScreenState();
}

class _OHLCChartScreenState extends BaseChartScreenState<OHLCChartScreen> {
  Color _bullishBodyColor = CandleBullishThemeColors.candleBullishBodyDefault;
  Color _bearishBodyColor = CandleBearishThemeColors.candleBearishBodyDefault;
  Color _bullishWickColor = CandleBullishThemeColors.candleBullishWickDefault;
  Color _bearishWickColor = CandleBearishThemeColors.candleBearishWickDefault;

  @override
  String getTitle() => 'OHLC Chart';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('ohlc_chart'),
      mainSeries: OhlcCandleSeries(
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
      activeSymbol: 'OHLC_CHART',
      useDrawingToolsV2: true,
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
