import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tools_dialog.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicators_dialog.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/misc/chart_controller.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chart/chart.dart';
import 'chart/data_visualization/models/chart_object.dart';

/// A wrapper around the [Chart] which handles adding indicators to the chart.
class DerivChart extends StatefulWidget {
  /// Initializes
  const DerivChart({
    required this.mainSeries,
    required this.granularity,
    required this.currentSymbolName,
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

  /// Current symbol name.
  final String currentSymbolName;

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
  late final AddOnsRepository<DrawingToolConfig> _drawingToolsRepo =
      AddOnsRepository<DrawingToolConfig>(DrawingToolConfig,
          currentSymbolName: widget.currentSymbolName);

  /// Selected drawing tool.
  DrawingToolConfig? _selectedDrawingTool;

  /// Existing drawings.
  final Map<String, List<Map<String, dynamic>>> _drawings =
      <String, List<Map<String, dynamic>>>{};

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
        element.loadFromPrefs(
            prefs,
            element is AddOnsRepository<DrawingToolConfig>
                ? widget.currentSymbolName
                : null);
      } on Exception {
        // ignore: unawaited_futures
        showDialog<void>(
            context: context,
            builder: (BuildContext context) => AnimatedPopupDialog(
                  child: Center(
                    child: element is AddOnsRepository<IndicatorConfig>
                        ? Text(ChartLocalization.of(context)
                            .warnFailedLoadingIndicators)
                        : Text(ChartLocalization.of(context)
                            .warnFailedLoadingDrawingTools),
                  ),
                ));
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
                currentSymbolName: widget.currentSymbolName,
                drawings: _drawings,
                onAddDrawing: _onAddDrawing,
                selectedDrawingTool: _selectedDrawingTool,
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
                    showDialog<void>(
                        context: context,
                        builder: (
                          BuildContext context,
                        ) =>
                            ChangeNotifierProvider<
                                AddOnsRepository<DrawingToolConfig>>.value(
                              value: _drawingToolsRepo,
                              child: DrawingToolsDialog(
                                currentSymbolName: widget.currentSymbolName,
                                onDrawingToolRemoval: (int index) {
                                  setState(() {
                                    if (_drawings[widget.currentSymbolName] !=
                                        null) {
                                      _drawings[widget.currentSymbolName]!
                                          .removeAt(index);
                                    }
                                  });
                                },
                                onDrawingToolSelection:
                                    (DrawingToolConfig selectedDrawingTool) {
                                  setState(() {
                                    _selectedDrawingTool = selectedDrawingTool;
                                  });
                                },
                                onDrawingToolUpdate: (int index,
                                    DrawingToolConfig updatedConfig) {
                                  setState(() {
                                    if (_drawings[widget.currentSymbolName] !=
                                        null) {
                                      _drawings[widget.currentSymbolName]![
                                          index]['config'] = updatedConfig;
                                    }
                                  });
                                },
                              ),
                            ));
                  },
                ),
              ),
            ],
          ),
        ),
      );

  void _onAddDrawing(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished = false}) {
    setState(() {
      final dynamic _currentSymbolDrawings =
          _drawings[widget.currentSymbolName] ?? <Map<String, dynamic>>[];
      final String drawingId = addedDrawing.keys.first;

      final Map<String, dynamic> existingDrawing =
          _currentSymbolDrawings.firstWhere(
              (Map<String, dynamic> drawing) =>
                  drawing.isNotEmpty && drawing['id'] == drawingId,
              orElse: () => <String, dynamic>{});

      if (existingDrawing.isEmpty) {
        _currentSymbolDrawings.add(<String, dynamic>{
          'id': drawingId,
          'config': _selectedDrawingTool,
          'drawing': addedDrawing.values.first,
        });
      } else {
        existingDrawing['drawing'] = addedDrawing.values.first;
      }
      _drawings[widget.currentSymbolName] = _currentSymbolDrawings;

      if (isDrawingFinished) {
        _drawingToolsRepo.add(_selectedDrawingTool!, widget.currentSymbolName);
        _selectedDrawingTool = null;
      }
    });
  }
}
