import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:showcase_app/screens/chart_examples/base_chart_screen.dart';

/// Screen that displays information about drawing tools.
class DrawingToolsScreen extends BaseChartScreen {
  /// Initialize the drawing tools screen.
  const DrawingToolsScreen({Key? key}) : super(key: key);

  @override
  State<DrawingToolsScreen> createState() => _DrawingToolsScreenState();
}

class _DrawingToolsScreenState extends BaseChartScreenState<DrawingToolsScreen> {
  @override
  String getTitle() => 'Drawing Tools';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('drawing_tools_chart'),
      mainSeries: LineSeries(ticks, style: const LineStyle(hasArea: true)),
      controller: controller,
      pipSize: 2,
      granularity: 60000, // 1 minute
      activeSymbol: 'DRAWING_TOOLS_CHART',
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Drawing Tools Available in Deriv Chart',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'The Deriv Chart library supports various drawing tools including:',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToolChip('Line', Icons.show_chart),
              _buildToolChip('Horizontal', Icons.horizontal_rule),
              _buildToolChip('Vertical', Icons.vertical_align_center),
              _buildToolChip('Ray', Icons.trending_up),
              _buildToolChip('Trend', Icons.timeline),
              _buildToolChip('Rectangle', Icons.crop_square),
              _buildToolChip('Channel', Icons.view_stream),
              _buildToolChip('Fibonacci Fan', Icons.filter_tilt_shift),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'For implementation details, please refer to the documentation.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildToolChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}
