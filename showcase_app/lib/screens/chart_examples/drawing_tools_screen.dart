import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      granularity: 60000, // 1 minute
      activeSymbol: 'DRAWING_TOOLS_CHART',
      drawingTools: _drawingTools,
      drawingToolsRepo: _drawingToolsRepo,
      theme: ChartDefaultDarkTheme(), // Explicitly set dark theme
    );
  }

  void _showDrawingToolsDialog() {
    if (!_isInitialized) {
      return;
    }

    _drawingTools.init();

    // Create a simpler dialog with the necessary localization
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          ChartLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        theme: Theme.of(context),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            backgroundColor: Colors.transparent,
            body: ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
              value: _drawingToolsRepo,
              child: DrawingToolsDialog(
                drawingTools: _drawingTools,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addDrawingTool() {
    if (!_isInitialized || _selectedDrawingTool == null) {
      return;
    }

    _drawingTools.onDrawingToolSelection(_selectedDrawingTool!);
    _drawingToolsRepo.update();
    setState(() {
      _selectedDrawingTool = null;
    });
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
                      items: const <DropdownMenuItem<DrawingToolConfig>>[
                        DropdownMenuItem<DrawingToolConfig>(
                          value: LineDrawingToolConfig(),
                          child: Text('Line'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: HorizontalDrawingToolConfig(),
                          child: Text('Horizontal'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: VerticalDrawingToolConfig(),
                          child: Text('Vertical'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: RayDrawingToolConfig(),
                          child: Text('Ray'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: TrendDrawingToolConfig(),
                          child: Text('Trend'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: RectangleDrawingToolConfig(),
                          child: Text('Rectangle'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: ChannelDrawingToolConfig(),
                          child: Text('Channel'),
                        ),
                        DropdownMenuItem<DrawingToolConfig>(
                          value: FibfanDrawingToolConfig(),
                          child: Text('Fibonacci Fan'),
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
