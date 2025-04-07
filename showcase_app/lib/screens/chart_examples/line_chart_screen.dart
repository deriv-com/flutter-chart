import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

/// Screen that displays a line chart example.
class LineChartScreen extends BaseChartScreen {
  /// Initialize the line chart screen.
  const LineChartScreen({Key? key}) : super(key: key);

  @override
  State<LineChartScreen> createState() => _LineChartScreenState();
}

class _LineChartScreenState extends BaseChartScreenState<LineChartScreen> {
  bool _hasArea = true;
  double _thickness = 2;
  Color _lineColor = Colors.blue;
  bool _showTickIndicator = true;
  TickIndicator? _tickIndicator;

  @override
  void initState() {
    super.initState();
    // Initialize tick indicator after the frame is rendered to ensure ticks are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTickIndicator();
    });
  }

  @override
  void didUpdateWidget(LineChartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize tick indicator when the widget updates
    _initializeTickIndicator();
  }

  void _initializeTickIndicator() {
    if (ticks.isEmpty) {
      debugPrint('Ticks list is empty, cannot initialize tick indicator');
      return;
    }

    final lastTick = ticks.last;

    _tickIndicator = TickIndicator(
      lastTick,
      style: HorizontalBarrierStyle(
        color: _lineColor, // Match the line color
        labelShape: LabelShape.pentagon,
        hasBlinkingDot: true,
        hasArrow: false,
      ),
      visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
    );

    // Force a rebuild to show the tick indicator
    if (mounted) {
      setState(() {});
    }
  }

  @override
  String getTitle() => 'Line Chart';

  @override
  Widget buildChart() {
    final List<ChartAnnotation<ChartObject>> annotations = [];

    if (_showTickIndicator && ticks.isNotEmpty && _tickIndicator != null) {
      annotations.add(_tickIndicator!);
    }

    return DerivChart(
      key: const Key('line_chart'),
      mainSeries: LineSeries(
        ticks,
        style: LineStyle(
          hasArea: _hasArea,
          thickness: _thickness,
          color: _lineColor,
        ),
      ),
      annotations: annotations,
      controller: controller,
      pipSize: 2,
      granularity: 60000, // 1 minute
      activeSymbol: 'LINE_CHART',
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tick indicator toggle
          Row(
            children: [
              const Text('Tick Indicator:'),
              const SizedBox(width: 8),
              Switch(
                value: _showTickIndicator,
                onChanged: (value) {
                  setState(() {
                    _showTickIndicator = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Area Fill:'),
              const SizedBox(width: 8),
              Switch(
                value: _hasArea,
                onChanged: (value) {
                  setState(() {
                    _hasArea = value;
                  });
                },
              ),
              const SizedBox(width: 16),
              const Text('Thickness:'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _thickness,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _thickness.toString(),
                  onChanged: (value) {
                    setState(() {
                      _thickness = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Color:'),
              const SizedBox(width: 8),
              _buildColorButton(Colors.blue),
              _buildColorButton(Colors.red),
              _buildColorButton(Colors.green),
              _buildColorButton(Colors.orange),
              _buildColorButton(Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _lineColor = color;
            // Update tick indicator color when line color changes
            _initializeTickIndicator();
          });
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: _lineColor == color ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
