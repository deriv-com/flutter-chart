import 'package:collection/collection.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tools_dialog.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicators_dialog.dart';
import 'package:deriv_chart/src/deriv_chart/chart/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_object.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/misc/chart_controller.dart';
import 'package:deriv_chart/src/misc/extensions.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A wrapper around the [Chart] which handles adding indicators to the chart.
class DerivChart extends StatefulWidget {
  /// Initializes
  const DerivChart({
    required this.mainSeries,
    required this.granularity,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.onVisibleAreaChanged,
    this.theme,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.annotations,
    this.opacity = 1.0,
    this.pipSize = 4,
    Key? key,
  }) : super(key: key);

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Chart's controller
  final ChartController? controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when crosshair details appear after long press.
  final VoidCallback? onCrosshairAppeared;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback? onVisibleAreaChanged;

  /// Chart's theme.
  final ChartTheme? theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// Whether the chart should be showing live data or not.
  ///
  /// In case of being true the chart will keep auto-scrolling when its visible
  /// area is on the newest ticks/candles.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  @override
  _DerivChartState createState() => _DerivChartState();
}

class _DerivChartState extends State<DerivChart> {
  final AddOnsRepository<IndicatorConfig> _indicatorsRepo =
      AddOnsRepository<IndicatorConfig>(IndicatorConfig);
  final AddOnsRepository<DrawingToolConfig> _drawingToolsRepo =
      AddOnsRepository<DrawingToolConfig>(DrawingToolConfig);

  // check if first point of any drawing is clicked
  bool isFirstPointOfNewDrawing = false;

  /// Selected drawing tool.
  DrawingToolConfig? _selectedDrawingTool;

  /// Existing drawings.
  final List<DrawingData> _drawings = <DrawingData>[];

  @override
  void initState() {
    super.initState();

    loadSavedIndicatorsAndDrawingTools();
  }

  Future<void> loadSavedIndicatorsAndDrawingTools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<dynamic> _stateRepos = <dynamic>[
      _indicatorsRepo,
      _drawingToolsRepo
    ];
    _stateRepos.asMap().forEach((int index, dynamic element) {
      try {
        element.loadFromPrefs(prefs);
      } on Exception {
        // ignore: unawaited_futures
        showDialog<void>(
          context: context,
          builder: (BuildContext context) => AnimatedPopupDialog(
            child: Center(
              child: element is AddOnsRepository<IndicatorConfig>
                  ? Text(context.localization.warnFailedLoadingIndicators)
                  : Text(context.localization.warnFailedLoadingDrawingTools),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<AddOnsRepository<IndicatorConfig>>.value(
              value: _indicatorsRepo),
          ChangeNotifierProvider<AddOnsRepository<DrawingToolConfig>>.value(
              value: _drawingToolsRepo),
        ],
        child: Builder(
          builder: (BuildContext context) => Stack(
            children: <Widget>[
              Chart(
                mainSeries: widget.mainSeries,
                pipSize: widget.pipSize,
                granularity: widget.granularity,
                isFirstPointOfNewDrawing: isFirstPointOfNewDrawing,
                controller: widget.controller,
                overlaySeries: <Series>[
                  ...context
                      .watch<AddOnsRepository<IndicatorConfig>>()
                      .addOns
                      .where((IndicatorConfig indicatorConfig) =>
                          indicatorConfig.isOverlay)
                      .map((IndicatorConfig indicatorConfig) =>
                          indicatorConfig.getSeries(
                            IndicatorInput(
                              widget.mainSeries.input,
                              widget.granularity,
                            ),
                          ))
                ],
                bottomSeries: <Series>[
                  ...context
                      .watch<AddOnsRepository<IndicatorConfig>>()
                      .addOns
                      .where((IndicatorConfig indicatorConfig) =>
                          !indicatorConfig.isOverlay)
                      .map((IndicatorConfig indicatorConfig) =>
                          indicatorConfig.getSeries(
                            IndicatorInput(
                              widget.mainSeries.input,
                              widget.granularity,
                            ),
                          ))
                ],
                drawings: _drawings,
                onAddDrawing: _onAddDrawing,
                selectedDrawingTool: _selectedDrawingTool,
                clearDrawingToolSelection: _clearDrawingToolSelection,
                markerSeries: widget.markerSeries,
                theme: widget.theme,
                onCrosshairAppeared: widget.onCrosshairAppeared,
                onVisibleAreaChanged: widget.onVisibleAreaChanged,
                isLive: widget.isLive,
                dataFitEnabled: widget.dataFitEnabled,
                opacity: widget.opacity,
                annotations: widget.annotations,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.architecture),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (
                        BuildContext context,
                      ) =>
                          ChangeNotifierProvider<
                              AddOnsRepository<IndicatorConfig>>.value(
                        value: _indicatorsRepo,
                        child: IndicatorsDialog(),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: const FractionalOffset(0.1, 0),
                child: IconButton(
                  icon: const Icon(Icons.drive_file_rename_outline_outlined),
                  onPressed: () {
                    /// Remove unfinished drawings before openning the dialog.
                    /// For the scenario where the user adds part of a drawing
                    /// and then opens the dialog.
                    setState(() {
                      _drawings.removeWhere(
                          (DrawingData data) => !data.isDrawingFinished);
                      _selectedDrawingTool = null;
                    });

                    showDialog<void>(
                      context: context,
                      builder: (
                        BuildContext context,
                      ) =>
                          ChangeNotifierProvider<
                              AddOnsRepository<DrawingToolConfig>>.value(
                        value: _drawingToolsRepo,
                        child: DrawingToolsDialog(
                          onDrawingToolRemoval: (int index) {
                            if (_drawings.isNotEmpty) {
                              setState(() {
                                isFirstPointOfNewDrawing = false;
                                _drawings.removeAt(index);
                              });
                            }
                          },
                          onDrawingToolSelection:
                              (DrawingToolConfig selectedDrawingTool) {
                            setState(() {
                              isFirstPointOfNewDrawing = true;
                              _selectedDrawingTool = selectedDrawingTool;
                            });
                          },
                          onDrawingToolUpdate:
                              (int index, DrawingToolConfig updatedConfig) {
                            setState(() {
                              _drawings[index] =
                                  _drawings[index].updateConfig(updatedConfig);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  void _onAddDrawing(
    Map<String, List<Drawing>> addedDrawing, {
    bool isDrawingFinished = false,
  }) {
    setState(() {
      final String drawingId = addedDrawing.keys.first;

      final DrawingData? existingDrawing = _drawings.firstWhereOrNull(
        (DrawingData drawing) => drawing.id == drawingId,
      );

      if (existingDrawing == null) {
        _drawings.add(DrawingData(
          id: drawingId,
          config: _selectedDrawingTool!,
          drawingParts: addedDrawing.values.first,
          isDrawingFinished: isDrawingFinished,
        ));
        if (drawingId.contains('horizontal') ||
            drawingId.contains('vertical')) {
          isFirstPointOfNewDrawing = false;
        }
      } else {
        isFirstPointOfNewDrawing = false;
        existingDrawing
          ..updateDrawingPartList(addedDrawing.values.first)
          ..isSelected = true
          ..isDrawingFinished = isDrawingFinished;
      }

      if (isDrawingFinished) {
        isFirstPointOfNewDrawing = false;
        _drawingToolsRepo.add(_selectedDrawingTool!);
        _selectedDrawingTool = null;
      }

      if (_drawings.length > 1) {
        _drawings.removeWhere((DrawingData data) =>
            data.id != drawingId && !data.isDrawingFinished);
      }
    });
  }

  /// Clean the drawing tool selection.
  void _clearDrawingToolSelection() {
    setState(() {
      _selectedDrawingTool = null;
    });
  }
}
