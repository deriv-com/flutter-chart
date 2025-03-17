import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:showcase_app/screens/chart_examples/base_chart_screen.dart';

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
  
  // Custom theme would be implemented here in a real app
  // For this example, we'll just switch between light and dark themes
  
  @override
  String getTitle() => 'Theme Customization';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('theme_customization_chart'),
      mainSeries: CandleSeries(candles),
      controller: controller,
      pipSize: 2,
      granularity: 3600000, // 1 hour
      theme: _useDarkTheme ? null : ChartDefaultLightTheme(),
      activeSymbol: 'THEME_CUSTOMIZATION_CHART',
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
          const Text(
            'The chart library supports both light and dark themes, as well as fully customizable themes.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'You can create custom themes by extending ChartDefaultDarkTheme or ChartDefaultLightTheme.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
