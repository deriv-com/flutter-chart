import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../../widgets/color_picker_widget.dart';
import 'base_chart_screen.dart';

/// A custom theme that extends the default dark theme.
class CustomDarkTheme extends ChartDefaultDarkTheme {
  /// Initialize the custom dark theme.
  CustomDarkTheme({
    required this.customGridColor,
    required this.customBullishColor,
    required this.customBearishColor,
    required this.customBackgroundColor,
  });

  /// custom grid color
  final Color customGridColor;

  /// Custom bullish color.
  final Color customBullishColor;

  /// Custom bearish color.
  final Color customBearishColor;

  /// Custom background color.
  final Color customBackgroundColor;

  @override
  Color get backgroundColor => customBackgroundColor;

  @override
  Color get gridLineColor => customGridColor;

  @override
  Color get candleBullishBodyDefault => customBullishColor;

  @override
  Color get candleBullishWickDefault => customBullishColor;

  @override
  Color get candleBearishBodyDefault => customBearishColor;

  @override
  Color get candleBearishWickDefault => customBearishColor;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: customGridColor,
        xLabelStyle: textStyle(
          textStyle: gridTextStyle,
          color: gridTextColor,
        ),
        yLabelStyle: textStyle(
          textStyle: gridTextStyle,
          color: gridTextColor,
        ),
      );

  @override
  CandleStyle get candleStyle => CandleStyle(
      candleBullishBodyColor: customBullishColor,
      candleBearishBodyColor: customBearishColor,
      candleBullishWickColor: customBullishColor,
      candleBearishWickColor: customBearishColor,
      neutralColor: base04Color);
}

/// A custom theme that extends the default light theme.
class CustomLightTheme extends ChartDefaultLightTheme {
  /// Initialize the custom light theme.
  CustomLightTheme({
    required this.customGridColor,
    required this.customBullishColor,
    required this.customBearishColor,
    required this.customBackgroundColor,
  });

  /// custom grid color
  final Color customGridColor;

  /// Custom bullish color.
  final Color customBullishColor;

  /// Custom bearish color.
  final Color customBearishColor;

  /// Custom background color.
  final Color customBackgroundColor;

  @override
  Color get backgroundColor => customBackgroundColor;

  @override
  Color get gridLineColor => customGridColor;

  @override
  Color get candleBullishBodyDefault => customBullishColor;

  @override
  Color get candleBullishWickDefault => customBullishColor;

  @override
  Color get candleBearishBodyDefault => customBearishColor;

  @override
  Color get candleBearishWickDefault => customBearishColor;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: customGridColor,
        xLabelStyle: textStyle(
          textStyle: gridTextStyle,
          color: gridTextColor,
        ),
        yLabelStyle: textStyle(
          textStyle: gridTextStyle,
          color: gridTextColor,
        ),
      );

  @override
  CandleStyle get candleStyle => CandleStyle(
      candleBullishBodyColor: customBullishColor,
      candleBearishBodyColor: customBearishColor,
      candleBullishWickColor: customBullishColor,
      candleBearishWickColor: customBearishColor,
      neutralColor: base04Color);
}

/// Screen that displays a chart with theme customization.
class ThemeCustomizationScreen extends BaseChartScreen {
  /// Initialize the theme customization screen.
  const ThemeCustomizationScreen({Key? key}) : super(key: key);

  @override
  State<ThemeCustomizationScreen> createState() =>
      _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState
    extends BaseChartScreenState<ThemeCustomizationScreen> {
  bool _useDarkTheme = true;
  bool _useCustomTheme = false;

  // Custom theme colors
  Color _gridColor = const Color(0xFF323738);
  Color _candleBullishBodyColor = Colors.green;
  Color _candleBearishBodyColor = Colors.red;
  Color _backgroundColor =
      const Color(0xFF181C25); // Default dark theme background

  @override
  String getTitle() => 'Theme Customization';

  @override
  Widget buildChart() {
    ChartTheme theme;

    if (_useCustomTheme) {
      if (_useDarkTheme) {
        theme = CustomDarkTheme(
          customGridColor: _gridColor,
          customBullishColor: _candleBullishBodyColor,
          customBearishColor: _candleBearishBodyColor,
          customBackgroundColor: _backgroundColor,
        );
      } else {
        theme = CustomLightTheme(
          customGridColor: _gridColor,
          customBullishColor: _candleBullishBodyColor,
          customBearishColor: _candleBearishBodyColor,
          customBackgroundColor: _backgroundColor,
        );
      }
    } else {
      theme =
          _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme();
    }

    return DerivChart(
      key: const Key('theme_customization_chart'),
      mainSeries: CandleSeries(candles),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      theme: theme,
      activeSymbol: 'THEME_CUSTOMIZATION_CHART',
      useDrawingToolsV2: true,
    );
  }

  Widget _buildColorPicker(
      String label, Color currentColor, Function(Color) onColorChanged) {
    return DerivColorPicker(
      label: label,
      selectedColor: currentColor,
      onColorChanged: onColorChanged,
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme type selection
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Theme:'),
                  const SizedBox(width: 8),
                  const Text('Light'),
                  Switch(
                    value: _useDarkTheme,
                    onChanged: (value) {
                      setState(() {
                        _useDarkTheme = value;

                        // Update default colors based on theme
                        if (_useCustomTheme) {
                          if (value) {
                            // Dark theme
                            _gridColor = const Color(0xFF323738);
                            _backgroundColor = const Color(0xFF181C25);
                          } else {
                            // Light theme
                            _gridColor = const Color(0xFFE0E0E0);
                            _backgroundColor = const Color(0xFFFFFFFF);
                          }
                        }
                      });
                    },
                  ),
                  const Text('Dark'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Custom Theme:'),
                  const SizedBox(width: 8),
                  Switch(
                    value: _useCustomTheme,
                    onChanged: (value) {
                      setState(() {
                        _useCustomTheme = value;

                        // Set default colors based on current theme
                        if (value) {
                          if (_useDarkTheme) {
                            _gridColor = const Color(0xFF323738);
                            _backgroundColor = const Color(0xFF181C25);
                          } else {
                            _gridColor = const Color(0xFFE0E0E0);
                            _backgroundColor = const Color(0xFFFFFFFF);
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Custom theme controls
          if (_useCustomTheme) ...[
            const Text(
              'Customize Theme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Color pickers
            _buildColorPicker('Bullish Color:', _candleBullishBodyColor,
                (color) {
              setState(() {
                _candleBullishBodyColor = color;
              });
            }),
            const SizedBox(height: 8),

            _buildColorPicker('Bearish Color:', _candleBearishBodyColor,
                (color) {
              setState(() {
                _candleBearishBodyColor = color;
              });
            }),
            const SizedBox(height: 8),

            _buildColorPicker('Grid Color:', _gridColor, (color) {
              setState(() {
                _gridColor = color;
              });
            }),
            const SizedBox(height: 8),

            _buildColorPicker('Background Color:', _backgroundColor, (color) {
              setState(() {
                _backgroundColor = color;
              });
            }),
            const SizedBox(height: 8),
          ] else ...[
            const Text(
              'The chart library supports both light and dark themes, as well as fully customizable themes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable "Custom Theme" to see theme customization options.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
