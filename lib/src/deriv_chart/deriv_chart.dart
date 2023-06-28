import 'package:collection/collection.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tools_dialog.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicators_dialog.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
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
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onVisibleAreaChanged,
    this.onQuoteAreaChanged,
    this.theme,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.showCrosshair = true,
    this.annotations,
    this.opacity = 1.0,
    this.pipSize = 4,
    this.indicatorsRepo,
    this.drawingToolsRepo,
    this.maxCurrentTickOffset,
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

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHoverCallback? onCrosshairHover;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback? onVisibleAreaChanged;

  /// Callback provided by library user.
  final VisibleQuoteAreaChangedCallback? onQuoteAreaChanged;

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

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Max distance between rightBoundEpoch and nowEpoch in pixels.
  final double? maxCurrentTickOffset;

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  /// Chart's drawings
  final Repository<DrawingToolConfig>? drawingToolsRepo;

  @override
  _DerivChartState createState() => _DerivChartState();
}

class _DerivChartState extends State<DerivChart> {
  late AddOnsRepository<IndicatorConfig> _indicatorsRepo;

  late AddOnsRepository<DrawingToolConfig> _drawingToolsRepo;

  /// Selected drawing tool.
  DrawingToolConfig? _selectedDrawingTool;

  /// Existing drawings.
  final List<DrawingData> _drawings = <DrawingData>[];

  @override
  void initState() {
    super.initState();

    loadSavedIndicatorsAndDrawingTools();
    _initRepos();
  }

  void _initRepos() {
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      onEditCallback: showIndicatorsDialog,
    );

    _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) =>
          DrawingToolConfig.fromJson(map),
      onEditCallback: showDrawingToolsDialog,
    );
  }

  Future<void> loadSavedIndicatorsAndDrawingTools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<AddOnsRepository<AddOnConfig>> _stateRepos =
        <AddOnsRepository<AddOnConfig>>[_indicatorsRepo, _drawingToolsRepo];

    _stateRepos.asMap().forEach((int index, dynamic element) {
      try {
        element.loadFromPrefs(prefs);
      } on Exception {
        // ignore: unawaited_futures
        showDialog<void>(
          context: context,
          builder: (BuildContext context) => AnimatedPopupDialog(
            child: Center(
              child: element is Repository<IndicatorConfig>
                  ? Text(context.localization.warnFailedLoadingIndicators)
                  : Text(context.localization.warnFailedLoadingDrawingTools),
            ),
          ),
        );
      }
    });
  }

  void showIndicatorsDialog() {
    showDialog<void>(
      context: context,
      builder: (
        BuildContext context,
      ) =>
          ChangeNotifierProvider<Repository<IndicatorConfig>>.value(
        value: _indicatorsRepo,
        child: IndicatorsDialog(),
      ),
    );
  }

  void showDrawingToolsDialog() {
    /// Remove unfinished drawings before openning the dialog.
    /// For the scenario where the user adds part of a drawing
    /// and then opens the dialog.
    setState(() {
      _drawings.removeWhere((DrawingData data) => !data.isDrawingFinished);
      _selectedDrawingTool = null;
    });

    showDialog<void>(
      context: context,
      builder: (
        BuildContext context,
      ) =>
          ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
        value: _drawingToolsRepo,
        child: DrawingToolsDialog(
          onDrawingToolRemoval: (int index) {
            setState(() {
              _drawings.removeAt(index);
            });
          },
          onDrawingToolSelection: (DrawingToolConfig selectedDrawingTool) {
            setState(() {
              _selectedDrawingTool = selectedDrawingTool;
            });
          },
          onDrawingToolUpdate: (int index, DrawingToolConfig updatedConfig) {
            setState(() {
              _drawings[index] = _drawings[index].updateConfig(updatedConfig);
            });
          },
        ),
      ),
    );
  }

  Widget _buildIndicatorsIcon() => Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: const Icon(Icons.architecture),
          onPressed: showIndicatorsDialog,
        ),
      );

  Widget _buildDrawingToolsIcon() => Align(
        alignment: const FractionalOffset(0.1, 0),
        child: IconButton(
          icon: const Icon(Icons.drive_file_rename_outline_outlined),
          onPressed: showDrawingToolsDialog,
        ),
      );

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <ChangeNotifierProvider<Repository<AddOnConfig>>>[
          ChangeNotifierProvider<Repository<IndicatorConfig>>.value(
              value: widget.indicatorsRepo ?? _indicatorsRepo),
          ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
              value: widget.drawingToolsRepo ?? _drawingToolsRepo),
        ],
        child: Builder(
          builder: (BuildContext context) => Stack(
            children: <Widget>[
              Chart(
                mainSeries: widget.mainSeries,
                pipSize: widget.pipSize,
                granularity: widget.granularity,
                controller: widget.controller,
                overlayConfigs: <IndicatorConfig>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .where((IndicatorConfig config) => config.isOverlay)
                ],
                bottomConfigs: <IndicatorConfig>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .where((IndicatorConfig config) => !config.isOverlay)
                ],
                drawings: _drawings,
                onAddDrawing: _onAddDrawing,
                selectedDrawingTool: _selectedDrawingTool,
                clearDrawingToolSelection: _clearDrawingToolSelection,
                markerSeries: widget.markerSeries,
                theme: widget.theme,
                onCrosshairAppeared: widget.onCrosshairAppeared,
                onCrosshairDisappeared: widget.onCrosshairDisappeared,
                onCrosshairHover: widget.onCrosshairHover,
                onVisibleAreaChanged: widget.onVisibleAreaChanged,
                onQuoteAreaChanged: widget.onQuoteAreaChanged,
                isLive: widget.isLive,
                dataFitEnabled: widget.dataFitEnabled,
                opacity: widget.opacity,
                annotations: widget.annotations,
                showCrosshair: widget.showCrosshair,
                indicatorsRepo: widget.indicatorsRepo ?? _indicatorsRepo,
                maxCurrentTickOffset: widget.maxCurrentTickOffset,
              ),
              if (widget.indicatorsRepo == null) _buildIndicatorsIcon(),
              if (widget.drawingToolsRepo == null) _buildDrawingToolsIcon(),
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
      } else {
        existingDrawing
          ..updateDrawingPartList(addedDrawing.values.first)
          ..isSelected = true
          ..isDrawingFinished = isDrawingFinished;
      }

      if (isDrawingFinished) {
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
