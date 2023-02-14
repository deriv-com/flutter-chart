import 'package:collection/collection.dart';
import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tools_dialog.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicators_dialog.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
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

  /// Called when candle or point is dismissed.
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

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  /// Chart's drawings
  final Repository<DrawingToolConfig>? drawingToolsRepo;

  @override
  _DerivChartState createState() => _DerivChartState();
}

class _DerivChartState extends State<DerivChart> {
  _DerivChartState() {
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      IndicatorConfig,
      onEditCallback: showIndicatorsDialog,
    );

    _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
      DrawingToolConfig,
      onEditCallback: showDrawingToolsDialog,
    );
  }

  late AddOnsRepository<IndicatorConfig> _indicatorsRepo;

  late AddOnsRepository<DrawingToolConfig> _drawingToolsRepo;

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
                    child: element is Repository<IndicatorConfig>
                        ? Text(ChartLocalization.of(context)
                            .warnFailedLoadingIndicators)
                        : Text(ChartLocalization.of(context)
                            .warnFailedLoadingDrawingTools),
                  ),
                ));
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
    showDialog<void>(
      context: context,
      builder: (
        BuildContext context,
      ) =>
          ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
        value: _drawingToolsRepo,
        child: DrawingToolsDialog(),
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
        providers: <ChangeNotifierProvider<dynamic>>[
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
                overlaySeries: <Series>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .mapIndexed((int index, IndicatorConfig indicatorConfig) {
                        if (!indicatorConfig.isOverlay) {
                          return null;
                        }
                        return indicatorConfig.getSeries(
                          IndicatorInput(
                            widget.mainSeries.input,
                            widget.granularity,
                            id: indicatorConfig.id ?? index.toString(),
                          ),
                        );
                      })
                      .where((Series? series) => series != null)
                      .whereType<Series>()
                ],
                bottomSeries: <Series>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .mapIndexed((int index, IndicatorConfig indicatorConfig) {
                        if (indicatorConfig.isOverlay) {
                          return null;
                        }
                        return indicatorConfig.getSeries(
                          IndicatorInput(
                            widget.mainSeries.input,
                            widget.granularity,
                            id: indicatorConfig.id ?? index.toString(),
                          ),
                        );
                      })
                      .where((Series? series) => series != null)
                      .whereType<Series>()
                ],
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
              ),
              if (widget.indicatorsRepo == null) _buildIndicatorsIcon(),
              if (widget.drawingToolsRepo == null) _buildDrawingToolsIcon(),
            ],
          ),
        ),
      );
}
