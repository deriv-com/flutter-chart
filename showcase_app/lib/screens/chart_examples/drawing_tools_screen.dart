import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:provider/provider.dart';
import 'base_chart_screen.dart';

/// Screen that displays information about drawing tools.
class DrawingToolsScreen extends BaseChartScreen {
  /// Initialize the drawing tools screen.
  const DrawingToolsScreen({Key? key}) : super(key: key);

  @override
  State<DrawingToolsScreen> createState() => _DrawingToolsScreenState();
}

class _DrawingToolsScreenState
    extends BaseChartScreenState<DrawingToolsScreen> {
  final DrawingTools _drawingTools = DrawingTools();
  late final Repository<DrawingToolConfig> _drawingToolsRepo;
  DrawingToolConfig? _selectedDrawingTool;
  bool _isInitialized = false;
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

  final InteractiveLayerController interactiveLayerController =
      InteractiveLayerController();

  @override
  void initState() {
    super.initState();
    // Initialize in the next frame to ensure all dependencies are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDrawingTools();
    });
  }

  void _initializeDrawingTools() {
    if (_isInitialized) {
      return;
    }

    setState(() {
      _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
        createAddOn: (Map<String, dynamic> map) =>
            DrawingToolConfig.fromJson(map),
        sharedPrefKey: 'drawing_tools_screen',
      );

      _drawingTools.drawingToolsRepo = _drawingToolsRepo;
      _isInitialized = true;
    });
  }

  @override
  String getTitle() => 'Drawing Tools';

  @override
  Widget buildChart() {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return DerivChart(
      key: const Key('drawing_tools_chart'),
      mainSeries: LineSeries(ticks, style: const LineStyle(hasArea: true)),
      controller: controller,
      pipSize: 2,
      granularity: 60000,
      // 1 minute
      activeSymbol: 'DRAWING_TOOLS_CHART',
      drawingTools: _drawingTools,
      drawingToolsRepo: _drawingToolsRepo,
      theme: _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      showCrosshair: _showCrosshair,
      crosshairVariant: _useLargeScreenCrosshair
          ? CrosshairVariant.largeScreen
          : CrosshairVariant.smallScreen,
      useDrawingToolsV2: _useDrawingToolsV2,
    );
  }

  void _showDrawingToolsDialog() {
    if (!_isInitialized) {
      return;
    }

    _drawingTools.init();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
          value: _drawingToolsRepo,
          child: DrawingToolsDialog(
            drawingTools: _drawingTools,
            interactiveLayerController: interactiveLayerController,
          ),
        ),
      ),
    );
  }

  void _addDrawingTool() {
    if (_selectedDrawingTool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a drawing tool')),
      );
      return;
    }

    interactiveLayerController.startAddingNewTool(_selectedDrawingTool!);
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Drawing Tools',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

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

          if (!_isInitialized)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing drawing tools...'),
                ],
              ),
            )
          else
            Column(
              children: [
                // Drawing tool selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<DrawingToolConfig>(
                      value: _selectedDrawingTool,
                      hint: const Text('Select a drawing tool'),
                      items: <DropdownMenuItem<DrawingToolConfig>>[
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: LineDrawingToolConfig(),
                          child: Text('Trend Line'),
                        ),
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: HorizontalDrawingToolConfig(),
                          child: Text('Horizontal'),
                        ),
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: VerticalDrawingToolConfig(),
                          child: Text('Vertical'),
                        ),
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: RayDrawingToolConfig(),
                          child: Text('Ray'),
                        ),
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: TrendDrawingToolConfig(),
                          child: Text('Trend'),
                        ),
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: RectangleDrawingToolConfig(),
                          child: Text('Rectangle'),
                        ),
                        const DropdownMenuItem<DrawingToolConfig>(
                          value: ChannelDrawingToolConfig(),
                          child: Text('Channel'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: FibfanDrawingToolConfig(),
                          child: const Text('Fibonacci Fan'),
                        ),
                      ],
                      onChanged: (DrawingToolConfig? config) {
                        setState(() {
                          _selectedDrawingTool = config;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed:
                          _selectedDrawingTool != null ? _addDrawingTool : null,
                      child: const Text('Add'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Manage drawings button
                ElevatedButton.icon(
                  onPressed: _showDrawingToolsDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Manage Drawings'),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Instructions
          const Text(
            'Select a drawing tool from the dropdown and click "Add" to start drawing on the chart. '
            'Tap on the chart to place points for your drawing. '
            'Click "Manage Drawings" to edit or delete existing drawings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 16),

          // Available tools
          const Text(
            'Available Drawing Tools:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
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
        ],
      ),
    );
  }

  Widget _buildToolChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
