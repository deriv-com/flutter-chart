import 'package:flutter/material.dart';
import 'package:showcase_app/models/feature_item.dart';
import 'package:showcase_app/screens/chart_examples/line_chart_screen.dart';
import 'package:showcase_app/screens/chart_examples/candle_chart_screen.dart';
import 'package:showcase_app/screens/chart_examples/ohlc_chart_screen.dart';
import 'package:showcase_app/screens/chart_examples/hollow_candle_screen.dart';
import 'package:showcase_app/screens/chart_examples/indicators_screen.dart';
import 'package:showcase_app/screens/chart_examples/barriers_screen.dart';
import 'package:showcase_app/screens/chart_examples/markers_screen.dart';
import 'package:showcase_app/screens/chart_examples/drawing_tools_screen.dart';
import 'package:showcase_app/screens/chart_examples/theme_customization_screen.dart';

/// The home screen of the showcase app.
class HomeScreen extends StatelessWidget {
  /// Initialize the home screen.
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deriv Chart Showcase'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _featureItems.length,
        itemBuilder: (context, index) {
          final item = _featureItems[index];
          return _buildFeatureCard(context, item);
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, FeatureItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.screen),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Center(
                child: Icon(
                  item.icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List of feature items to display on the home screen.
  final List<FeatureItem> _featureItems = [
    FeatureItem(
      title: 'Line Chart',
      description: 'Basic line chart with customizable styles.',
      icon: Icons.show_chart,
      screen: const LineChartScreen(),
    ),
    FeatureItem(
      title: 'Candle Chart',
      description: 'Japanese candlestick chart for price movement analysis.',
      icon: Icons.candlestick_chart,
      screen: const CandleChartScreen(),
    ),
    FeatureItem(
      title: 'OHLC Chart',
      description: 'Open-High-Low-Close chart for price data visualization.',
      icon: Icons.bar_chart,
      screen: const OHLCChartScreen(),
    ),
    FeatureItem(
      title: 'Hollow Candle Chart',
      description: 'Hollow candlestick chart variation.',
      icon: Icons.candlestick_chart,
      screen: const HollowCandleScreen(),
    ),
    FeatureItem(
      title: 'Technical Indicators',
      description: 'Charts with technical indicators like Bollinger Bands, RSI, and MACD.',
      icon: Icons.analytics,
      screen: const IndicatorsScreen(),
    ),
    FeatureItem(
      title: 'Barriers',
      description: 'Charts with horizontal and vertical barriers and tick indicators.',
      icon: Icons.horizontal_rule,
      screen: const BarriersScreen(),
    ),
    FeatureItem(
      title: 'Markers',
      description: 'Charts with up/down markers and active marker details.',
      icon: Icons.place,
      screen: const MarkersScreen(),
    ),
    FeatureItem(
      title: 'Drawing Tools',
      description: 'Various drawing tools for technical analysis.',
      icon: Icons.edit,
      screen: const DrawingToolsScreen(),
    ),
    FeatureItem(
      title: 'Theme Customization',
      description: 'Customize chart appearance with different themes.',
      icon: Icons.palette,
      screen: const ThemeCustomizationScreen(),
    ),
  ];
}
