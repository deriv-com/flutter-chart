import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_object.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_controller.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/misc/chart_controller.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'interactive_layer/interactive_layer_behaviours/interactive_layer_behaviour.dart';
import 'interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';

/// A lite version of [DerivChart] that does not import dialog or
/// shared_preferences dependencies, keeping the web bundle smaller for
/// consumers that manage their own [indicatorsRepo] and [drawingToolsRepo].
class DerivChart extends StatefulWidget {
  /// Initializes
  const DerivChart({
    required this.mainSeries,
    required this.granularity,
    required this.activeSymbol,
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
    this.chartAxisConfig = const ChartAxisConfig(),
    this.indicatorsRepo,
    this.drawingToolsRepo,
    this.drawingTools,
    this.msPerPx,
    this.minIntervalWidth,
    this.maxIntervalWidth,
    this.dataFitPadding,
    this.currentTickAnimationDuration,
    this.quoteBoundsAnimationDuration,
    this.showCurrentTickBlinkAnimation,
    this.verticalPaddingFraction,
    this.bottomChartTitleMargin,
    this.showDataFitButton,
    this.showScrollToLastTickButton,
    this.loadingAnimationColor,
    this.crosshairVariant = CrosshairVariant.smallScreen,
    this.interactiveLayerBehaviour,
    this.useDrawingToolsV2 = false,
    Key? key,
  }) : super(key: key);

  /// Whether to use the new drawing tools v2 or not.
  final bool useDrawingToolsV2;

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Current active symbol.
  final String activeSymbol;

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

  /// Configurations for chart's axes.
  final ChartAxisConfig chartAxisConfig;

  /// Whether the chart should be showing live data or not.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  final double? maxIntervalWidth;

  /// Padding around data used in data-fit mode.
  final EdgeInsets? dataFitPadding;

  /// Duration of the current tick animated transition.
  final Duration? currentTickAnimationDuration;

  /// Duration of quote bounds animated transition.
  final Duration? quoteBoundsAnimationDuration;

  /// Whether to show current tick blink animation or not.
  final bool? showCurrentTickBlinkAnimation;

  /// Fraction of the chart's height taken by top or bottom padding.
  final double? verticalPaddingFraction;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  /// Whether the data fit button is shown or not.
  final bool? showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool? showScrollToLastTickButton;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  /// Chart's drawings
  final Repository<DrawingToolConfig>? drawingToolsRepo;

  /// Drawing tools
  final DrawingTools? drawingTools;

  /// The variant of the crosshair to be used.
  final CrosshairVariant crosshairVariant;

  /// Defines the behaviour that interactive layer should have.
  final InteractiveLayerBehaviour? interactiveLayerBehaviour;

  @override
  _DerivChartState createState() => _DerivChartState();
}

class _DerivChartState extends State<DerivChart> {
  late AddOnsRepository<IndicatorConfig> _indicatorsRepo;

  late AddOnsRepository<DrawingToolConfig> _drawingToolsRepo;

  final DrawingTools _drawingTools = DrawingTools();

  late final InteractiveLayerBehaviour _interactiveLayerBehaviour;

  @override
  void initState() {
    super.initState();

    _interactiveLayerBehaviour = widget.interactiveLayerBehaviour ??
        (kIsWeb
            ? InteractiveLayerDesktopBehaviour(
                controller: InteractiveLayerController())
            : InteractiveLayerMobileBehaviour(
                controller: InteractiveLayerController()));

    _initRepos();
  }

  void _initRepos() {
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      onEditCallback: (_) {},
      sharedPrefKey: widget.activeSymbol,
    );

    _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) =>
          DrawingToolConfig.fromJson(map),
      onEditCallback: (_) {},
      sharedPrefKey: widget.activeSymbol,
    );
  }

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
                drawingTools: widget.drawingTools ?? _drawingTools,
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
                msPerPx: widget.msPerPx,
                minIntervalWidth: widget.minIntervalWidth,
                maxIntervalWidth: widget.maxIntervalWidth,
                dataFitPadding: widget.dataFitPadding,
                currentTickAnimationDuration:
                    widget.currentTickAnimationDuration,
                quoteBoundsAnimationDuration:
                    widget.quoteBoundsAnimationDuration,
                showCurrentTickBlinkAnimation:
                    widget.showCurrentTickBlinkAnimation,
                verticalPaddingFraction: widget.verticalPaddingFraction,
                bottomChartTitleMargin: widget.bottomChartTitleMargin,
                showDataFitButton: widget.showDataFitButton,
                showScrollToLastTickButton: widget.showScrollToLastTickButton,
                loadingAnimationColor: widget.loadingAnimationColor,
                chartAxisConfig: widget.chartAxisConfig,
                crosshairVariant: widget.crosshairVariant,
                interactiveLayerBehaviour: _interactiveLayerBehaviour,
                useDrawingToolsV2: widget.useDrawingToolsV2,
              ),
            ],
          ),
        ),
      );
}
