import 'package:flutter/foundation.dart';
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
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

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

    final theme =
        _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme();

    _tickIndicator = TickIndicator(
      lastTick,
      style: theme.currentSpotStyle.copyWith(
          lineColor: _lineColor, labelShapeBackgroundColor: _lineColor),
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

    // Define theme for use in chart components
    final theme =
        _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme();

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
          areaGradientColors: (
            start: theme.areaGradientStart,
            end: theme.areaGradientEnd
          ),
        ),
      ),
      annotations: annotations,
      controller: controller,
      pipSize: 2,
      granularity: 60000, // 1 minute
      activeSymbol: 'LINE_CHART',
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
                    _initializeTickIndicator();
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
