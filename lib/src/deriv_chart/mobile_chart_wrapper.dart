import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicators_dialog.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_object.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/misc/chart_controller.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
import 'package:deriv_chart/src/misc/extensions.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:deriv_chart/src/widgets/chart_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'deriv_chart.dart';

/// The mobile version wrapper around the [Chart] which handles adding
/// indicators to the chart.
class MobileChartWrapper extends StatefulWidget {
  /// Initializes
  const MobileChartWrapper({
    required this.mainSeries,
    required this.granularity,
    required this.activeSymbol,
    this.toolsController,
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
    this.maxCurrentTickOffset,
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
    Key? key,
  }) : super(key: key);

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Current active symbol.
  final String activeSymbol;

  /// Chart's controller
  final ChartController? controller;

  /// Chart's tools controller.
  final ToolsController? toolsController;

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

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
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
  /// Quote scaling (drag on quote area) is controlled by this variable.
  final double? verticalPaddingFraction;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  /// Whether the data fit button is shown or not.
  final bool? showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool? showScrollToLastTickButton;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  @override
  _MobileChartWrapperState createState() => _MobileChartWrapperState();
}

class _MobileChartWrapperState extends State<MobileChartWrapper> {
  AddOnsRepository<IndicatorConfig>? _indicatorsRepo;

  // TODO(Ramin): Add AddOnsRepository<DrawingToolsConfig>? and DrawingTools
  //  for drawing tools.

  @override
  void initState() {
    super.initState();

    _initRepos();
    _setupController();
  }

  @override
  void didUpdateWidget(covariant MobileChartWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.activeSymbol != oldWidget.activeSymbol) {
      loadSavedIndicatorsAndDrawingTools();
    }
  }

  void _setupController() {
    widget.toolsController?.onShowIndicatorsToolsMenu = () {
      if (_indicatorsRepo != null) {
        _showIndicatorsSheet(_indicatorsRepo!);
      }
    };
  }

  void _initRepos() {
    if (widget.toolsController?.indicatorsEnabled ?? false) {
      _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
        createAddOn: (Map<String, dynamic> map) =>
            IndicatorConfig.fromJson(map),
        onEditCallback: (_) => _showIndicatorsSheet(_indicatorsRepo!),
        sharedPrefKey: widget.activeSymbol,
      );
    }

    loadSavedIndicatorsAndDrawingTools();
  }

  Future<void> loadSavedIndicatorsAndDrawingTools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<AddOnsRepository<AddOnConfig>> _stateRepos =
        <AddOnsRepository<AddOnConfig>>[
      if (_indicatorsRepo != null) _indicatorsRepo!,
      // TODO(Ramin): add drawing tools repo here.
    ];

    _stateRepos
        .asMap()
        .forEach((int index, AddOnsRepository<AddOnConfig> element) {
      try {
        element.loadFromPrefs(prefs, widget.activeSymbol);
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

  void _showIndicatorsSheet(AddOnsRepository<IndicatorConfig> indicatorsRepo) {
    // Show indicators menu as modal bottom sheet so it's dismissible by tapping
    // outside.
    showModalBottomSheet(
      context: context,
      builder: (_) => ChangeNotifierProvider<Repository<IndicatorConfig>>.value(
        value: indicatorsRepo,
        child: ChartBottomSheet(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            // TODO(Ramin): replace with the new indicators list widget.
            child: IndicatorsDialog(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      // TODO(Ramin): Check if we can consider using Chart widget directly.
      DerivChart(
        indicatorsRepo: _indicatorsRepo ??
            AddOnsRepository<IndicatorConfig>(
              createAddOn: (Map<String, dynamic> map) =>
                  IndicatorConfig.fromJson(map),
              sharedPrefKey: widget.activeSymbol,
            ),
        drawingToolsRepo: AddOnsRepository<DrawingToolConfig>(
          createAddOn: (Map<String, dynamic> map) =>
              DrawingToolConfig.fromJson(map),
          sharedPrefKey: widget.activeSymbol,
        ),
        controller: widget.controller,
        mainSeries: widget.mainSeries,
        markerSeries: widget.markerSeries,
        pipSize: widget.pipSize,
        granularity: widget.granularity,
        onVisibleAreaChanged: widget.onVisibleAreaChanged,
        isLive: widget.isLive,
        dataFitEnabled: widget.dataFitEnabled,
        opacity: widget.opacity,
        chartAxisConfig: widget.chartAxisConfig,
        annotations: widget.annotations,
        activeSymbol: widget.activeSymbol,
      );
}
