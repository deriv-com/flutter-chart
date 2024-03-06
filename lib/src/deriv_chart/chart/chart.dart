import 'package:collection/collection.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../add_ons/indicators_ui/indicator_config.dart';
import '../../add_ons/repository.dart';
import '../../misc/chart_controller.dart';
import '../../models/tick.dart';
import '../../theme/chart_default_dark_theme.dart';
import '../../theme/chart_theme.dart';
import 'bottom_chart.dart';
import 'data_visualization/annotations/chart_annotation.dart';
import 'data_visualization/chart_data.dart';
import 'data_visualization/chart_series/data_series.dart';
import 'data_visualization/chart_series/series.dart';
import 'data_visualization/markers/marker_series.dart';
import 'data_visualization/models/chart_object.dart';
import 'main_chart.dart';

const Duration _defaultDuration = Duration(milliseconds: 300);

/// Interactive chart widget.
class Chart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const Chart({
    required this.mainSeries,
    required this.granularity,
    required this.drawingTools,
    this.pipSize = 4,
    this.controller,
    this.overlayConfigs,
    this.bottomConfigs,
    this.markerSeries,
    this.theme,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onVisibleAreaChanged,
    this.onQuoteAreaChanged,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.opacity = 1.0,
    this.annotations,
    this.showCrosshair = false,
    this.indicatorsRepo,
    this.maxCurrentTickOffset,
    this.msPerPx,
    this.minIntervalWidth,
    this.maxIntervalWidth,
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

  /// Chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// List of overlay indicator series to add on chart beside the [mainSeries].
  final List<IndicatorConfig>? overlayConfigs;

  /// List of bottom indicator series to add on chart separate from the
  /// [mainSeries].
  final List<IndicatorConfig>? bottomConfigs;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools drawingTools;

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

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? maxIntervalWidth;

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

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  @override
  State<StatefulWidget> createState() => _ChartState();
}

// ignore: prefer_mixin
class _ChartState extends State<Chart> with WidgetsBindingObserver {
  bool? _followCurrentTick;
  late ChartController _controller;
  late ChartTheme _chartTheme;
  late List<Series>? bottomSeries;
  late List<Series>? overlaySeries;
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addObserver(this);
    _initChartController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initChartTheme();
  }

  void _initChartController() {
    _controller = widget.controller ?? ChartController();
  }

  List<Series>? _getIndicatorSeries(List<IndicatorConfig>? configs) {
    if (configs == null) {
      return null;
    }

    return configs
        .map((IndicatorConfig indicatorConfig) => indicatorConfig.getSeries(
              IndicatorInput(
                widget.mainSeries.input,
                widget.granularity,
              ),
            ))
        .toList();
  }

  void _initChartTheme() {
    _chartTheme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme());
  }

  void _onCrosshairHover(
    Offset globalPosition,
    Offset localPosition,
    EpochToX epochToX,
    QuoteToY quoteToY,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
  ) {
    widget.onCrosshairHover?.call(
      globalPosition,
      localPosition,
      epochToX,
      quoteToY,
      epochFromX,
      quoteFromY,
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChartConfig chartConfig = ChartConfig(
      pipSize: widget.pipSize,
      granularity: widget.granularity,
    );

    final List<Series>? overlaySeries =
        _getIndicatorSeries(widget.overlayConfigs);

    final List<Series>? bottomSeries =
        _getIndicatorSeries(widget.bottomConfigs);

    final List<ChartData> chartDataList = <ChartData>[
      widget.mainSeries,
      if (overlaySeries != null) ...overlaySeries,
      if (bottomSeries != null) ...bottomSeries,
      if (widget.annotations != null) ...widget.annotations!,
    ];

    _controller
      ..getSeriesList = (() => <Series>[
            if (overlaySeries != null) ...overlaySeries,
            if (bottomSeries != null) ...bottomSeries,
          ])
      ..getConfigsList = (() => <IndicatorConfig>[
            if (widget.overlayConfigs != null) ...?widget.overlayConfigs,
            if (widget.bottomConfigs != null) ...?widget.bottomConfigs,
          ]);

    final bool isExpanded = expandedIndex != null;

    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    final Duration quoteBoundsAnimationDuration =
        widget.quoteBoundsAnimationDuration ?? _defaultDuration;

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ChartTheme>.value(value: _chartTheme),
        Provider<ChartConfig>.value(value: chartConfig),
      ],
      child: Ink(
        color: _chartTheme.base08Color,
        child: GestureManager(
          child: XAxis(
            maxEpoch: chartDataList.getMaxEpoch(),
            minEpoch: chartDataList.getMinEpoch(),
            entries: widget.mainSeries.input,
            pipSize: widget.pipSize,
            onVisibleAreaChanged: _onVisibleAreaChanged,
            isLive: widget.isLive,
            startWithDataFitMode: widget.dataFitEnabled,
            maxCurrentTickOffset: widget.maxCurrentTickOffset,
            msPerPx: widget.msPerPx,
            minIntervalWidth: widget.minIntervalWidth,
            maxIntervalWidth: widget.maxIntervalWidth,
            scrollAnimationDuration: currentTickAnimationDuration,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: MainChart(
                    drawingTools: widget.drawingTools,
                    controller: _controller,
                    mainSeries: widget.mainSeries,
                    overlaySeries: overlaySeries,
                    annotations: widget.annotations,
                    markerSeries: widget.markerSeries,
                    pipSize: widget.pipSize,
                    onCrosshairAppeared: widget.onCrosshairAppeared,
                    onQuoteAreaChanged: widget.onQuoteAreaChanged,
                    isLive: widget.isLive,
                    showLoadingAnimationForHistoricalData:
                        !widget.dataFitEnabled,
                    showDataFitButton:
                        widget.showDataFitButton ?? widget.dataFitEnabled,
                    showScrollToLastTickButton:
                        widget.showScrollToLastTickButton ?? true,
                    opacity: widget.opacity,
                    verticalPaddingFraction: widget.verticalPaddingFraction,
                    showCrosshair: widget.showCrosshair,
                    onCrosshairDisappeared: widget.onCrosshairDisappeared,
                    onCrosshairHover: _onCrosshairHover,
                    loadingAnimationColor: widget.loadingAnimationColor,
                    currentTickAnimationDuration: currentTickAnimationDuration,
                    quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
                    showCurrentTickBlinkAnimation:
                        widget.showCurrentTickBlinkAnimation ?? true,
                  ),
                ),
                if (bottomSeries?.isNotEmpty ?? false)
                  ...bottomSeries!.mapIndexed((int index, Series series) {
                    if (isExpanded && expandedIndex != index) {
                      return const SizedBox.shrink();
                    }

                    return Expanded(
                      flex: isExpanded ? bottomSeries.length : 1,
                      child: BottomChart(
                        series: series,
                        granularity: widget.granularity,
                        pipSize: widget.bottomConfigs?[index].pipSize ??
                            widget.pipSize,
                        title: widget.bottomConfigs![index].title,
                        currentTickAnimationDuration:
                            currentTickAnimationDuration,
                        quoteBoundsAnimationDuration:
                            quoteBoundsAnimationDuration,
                        bottomChartTitleMargin: widget.bottomChartTitleMargin,
                        onRemove: () => _onRemove(widget.bottomConfigs![index]),
                        onEdit: () => _onEdit(widget.bottomConfigs![index]),
                        onExpandToggle: () {
                          setState(() {
                            expandedIndex =
                                expandedIndex != index ? index : null;
                          });
                        },
                        onSwap: (int offset) => _onSwap(
                            widget.bottomConfigs![index],
                            widget.bottomConfigs![index + offset]),
                        onCrosshairDisappeared: widget.onCrosshairDisappeared,
                        onCrosshairHover: (
                          Offset globalPosition,
                          Offset localPosition,
                          EpochToX epochToX,
                          QuoteToY quoteToY,
                          EpochFromX epochFromX,
                          QuoteFromY quoteFromY,
                        ) =>
                            widget.onCrosshairHover?.call(
                          globalPosition,
                          localPosition,
                          epochToX,
                          quoteToY,
                          epochFromX,
                          quoteFromY,
                          widget.bottomConfigs![index],
                        ),
                        isExpanded: isExpanded,
                        showCrosshair: widget.showCrosshair,
                        showExpandedIcon: bottomSeries.length > 1,
                        showMoveUpIcon: !isExpanded &&
                            bottomSeries.length > 1 &&
                            index != 0,
                        showMoveDownIcon: !isExpanded &&
                            bottomSeries.length > 1 &&
                            index != bottomSeries.length - 1,
                      ),
                    );
                  }).toList()
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onEdit(IndicatorConfig config) {
    if (widget.indicatorsRepo != null) {
      final int index = widget.indicatorsRepo!.items.indexOf(config);
      widget.indicatorsRepo!.editAt(index);
    }
  }

  void _onRemove(IndicatorConfig config) {
    expandedIndex = null;

    if (widget.indicatorsRepo != null) {
      final int index = widget.indicatorsRepo!.items.indexOf(config);
      widget.indicatorsRepo!.removeAt(index);
    }
  }

  void _onSwap(IndicatorConfig config1, IndicatorConfig config2) {
    if (widget.indicatorsRepo != null) {
      final int index1 = widget.indicatorsRepo!.items.indexOf(config1);
      final int index2 = widget.indicatorsRepo!.items.indexOf(config2);
      widget.indicatorsRepo!.swap(index1, index2);
    }
  }

  void _onVisibleAreaChanged(int leftBoundEpoch, int rightBoundEpoch) {
    widget.onVisibleAreaChanged?.call(leftBoundEpoch, rightBoundEpoch);

    // detect what is current viewing mode before lock the screen
    if (widget.mainSeries.entries != null &&
        widget.mainSeries.entries!.isNotEmpty) {
      if (rightBoundEpoch > widget.mainSeries.entries!.last.epoch) {
        _followCurrentTick = true;
      } else {
        _followCurrentTick = false;
      }
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    //scroll to last tick when screen is on
    if (state == AppLifecycleState.resumed &&
        _followCurrentTick != null &&
        _followCurrentTick!) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        _controller.onScrollToLastTick?.call(animate: false);
      });
    }
  }

  @override
  void dispose() {
    WidgetsFlutterBinding.ensureInitialized().removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if controller is set
    if (widget.controller != oldWidget.controller) {
      _initChartController();
    }
    if (widget.theme != oldWidget.theme) {
      _initChartTheme();
    }

    //check if entire entries changes(market or granularity changes)
    // scroll to last tick
    if (widget.mainSeries.entries != null &&
        widget.mainSeries.entries!.isNotEmpty) {
      if (widget.mainSeries.entries!.first.epoch !=
          oldWidget.mainSeries.entries!.first.epoch) {
        _controller.onScrollToLastTick?.call(animate: false);
      }
    }

    // Check if the the expanded bottom indicator is moved/removed.
    if (expandedIndex != null &&
        oldWidget.bottomConfigs?.length != widget.bottomConfigs?.length &&
        expandedIndex! < (oldWidget.bottomConfigs?.length ?? 0)) {
      final int? newIndex = widget.bottomConfigs
          ?.indexOf(oldWidget.bottomConfigs![expandedIndex!]);
      if (newIndex != expandedIndex) {
        expandedIndex = newIndex == -1 ? null : newIndex;
      }
    }
  }
}
