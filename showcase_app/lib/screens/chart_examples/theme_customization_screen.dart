import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:showcase_app/screens/chart_examples/base_chart_screen.dart';

/// A custom theme that extends the default dark theme.
class CustomChartTheme extends ChartDefaultDarkTheme {
  CustomChartTheme({
    required this.customGridColor,
    required this.customPositiveColor,
    required this.customNegativeColor,
    required this.customBackgroundColor,
  });

  final Color customGridColor;
  final Color customPositiveColor;
  final Color customNegativeColor;
  final Color customBackgroundColor;

  @override
  Color get base07Color => customGridColor;

  @override
  Color get base08Color => customBackgroundColor;

  @override
  Color get accentGreenColor => customPositiveColor;

  @override
  Color get accentRedColor => customNegativeColor;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: customGridColor,
        xLabelStyle: textStyle(
          textStyle: caption2,
          color: base03Color,
        ),
        yLabelStyle: textStyle(
          textStyle: caption2,
          color: base03Color,
        ),
      );

  @override
  CandleStyle get candleStyle => CandleStyle(
        positiveColor: customPositiveColor,
        negativeColor: customNegativeColor,
        neutralColor: base04Color,
      );
}

/// Screen that displays a chart with theme customization.
class ThemeCustomizationScreen extends BaseChartScreen {
  /// Initialize the theme customization screen.
  const ThemeCustomizationScreen({Key? key}) : super(key: key);

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends BaseChartScreenState<ThemeCustomizationScreen> {
  bool _useDarkTheme = true;
  bool _useCustomTheme = false;
  
  // Custom theme colors
  Color _gridColor = const Color(0xFF323738);
  Color _positiveColor = Colors.green;
  Color _negativeColor = Colors.red;
  Color _backgroundColor = const Color(0xFF151717);
  
  @override
  String getTitle() => 'Theme Customization';

  @override
  Widget buildChart() {
    ChartTheme theme;
    
    if (_useCustomTheme) {
      theme = CustomChartTheme(
        customGridColor: _gridColor,
        customPositiveColor: _positiveColor,
        customNegativeColor: _negativeColor,
        customBackgroundColor: _backgroundColor,
      );
    } else {
      theme = _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme();
    }
    
    return DerivChart(
      key: const Key('theme_customization_chart'),
      mainSeries: CandleSeries(candles),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      theme: theme,
      activeSymbol: 'THEME_CUSTOMIZATION_CHART',
    );
  }

  Widget _buildColorPicker(String label, Color currentColor, Function(Color) onColorChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label),
        ),
        const SizedBox(width: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildColorButton(Colors.red, currentColor, onColorChanged),
            _buildColorButton(Colors.green, currentColor, onColorChanged),
            _buildColorButton(Colors.blue, currentColor, onColorChanged),
            _buildColorButton(Colors.purple, currentColor, onColorChanged),
            _buildColorButton(Colors.orange, currentColor, onColorChanged),
            _buildColorButton(Colors.teal, currentColor, onColorChanged),
          ],
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color, Color currentColor, Function(Color) onColorChanged) {
    return InkWell(
      onTap: () => onColorChanged(color),
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
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    onChanged: _useCustomTheme ? null : (value) {
                      setState(() {
                        _useDarkTheme = value;
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
            _buildColorPicker('Positive Color:', _positiveColor, (color) {
              setState(() {
                _positiveColor = color;
              });
            }),
            const SizedBox(height: 8),
            
            _buildColorPicker('Negative Color:', _negativeColor, (color) {
              setState(() {
                _negativeColor = color;
              });
            }),
            const SizedBox(height: 8),
            
            _buildColorPicker('Grid Color:', _gridColor, (color) {
              setState(() {
                _gridColor = color;
              });
            }),
            const SizedBox(height: 8),
            
            _buildColorPicker('Background:', _backgroundColor, (color) {
              setState(() {
                _backgroundColor = color;
              });
            }),
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
