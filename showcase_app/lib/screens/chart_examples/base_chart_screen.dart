import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../../utils/chart_data_provider.dart';

/// Base class for all chart example screens.
abstract class BaseChartScreen extends StatefulWidget {
  /// Initialize the base chart screen.
  const BaseChartScreen({Key? key}) : super(key: key);
}

/// Base state class for all chart example screens.
abstract class BaseChartScreenState<T extends BaseChartScreen>
    extends State<T> {
  /// The chart controller.
  final ChartController controller = ChartController();

  /// The chart data.
  late List<Tick> ticks;

  /// The chart candles.
  late List<Candle> candles;

  /// Whether the controls section is expanded.
  bool _isControlsExpanded = true;

  @override
  void initState() {
    super.initState();
    ticks = ChartDataProvider.generateTicks();
    candles = ChartDataProvider.generateCandles();
  }

  /// Build the chart widget.
  Widget buildChart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isControlsExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: () {
              setState(() {
                _isControlsExpanded = !_isControlsExpanded;
              });
            },
            tooltip: _isControlsExpanded ? 'Hide Controls' : 'Show Controls',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: buildChart(),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isControlsExpanded ? 300 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isControlsExpanded ? 1.0 : 0.0,
              child: _isControlsExpanded
                  ? SingleChildScrollView(
                      child: buildControls(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  /// Get the title of the chart screen.
  String getTitle();

  /// Build the controls for the chart.
  Widget buildControls() {
    return const SizedBox(height: 50);
  }
}
