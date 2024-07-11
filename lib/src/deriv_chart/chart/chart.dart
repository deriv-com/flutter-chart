import 'package:collection/collection.dart';
import 'package:deriv_chart/src/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_wrapper.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
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
import 'bottom_chart_mobile.dart';
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
    this.drawingTools,
    this.pipSize = 4,
    this.controller,
    this.overlayConfigs,
    this.bottomConfigs = const <IndicatorConfig>[],
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
    this.chartAxisConfig = const ChartAxisConfig(),
    this.showCrosshair = false,
    this.indicatorsRepo,
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

  /// Chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// List of overlay indicator series to add on chart beside the [mainSeries].
  final List<IndicatorConfig>? overlayConfigs;

  /// List of bottom indicator series to add on chart separate from the
  /// [mainSeries].
  final List<IndicatorConfig> bottomConfigs;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools? drawingTools;

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

  /// Configurations for chart's axes.
  final ChartAxisConfig chartAxisConfig;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

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

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  @override
  State<StatefulWidget> createState() =>
      kIsWeb ? _ChartStateWeb() : _ChartStateMobile();
}

// ignore: prefer_mixin
abstract class _ChartState extends State<Chart> with WidgetsBindingObserver {
  bool? _followCurrentTick;
  late ChartController _controller;
  late ChartTheme _chartTheme;
  late List<Series>? bottomSeries;
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
      chartAxisConfig: widget.chartAxisConfig,
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
            ...widget.bottomConfigs,
          ]);

    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ChartTheme>.value(value: _chartTheme),
        Provider<ChartConfig>.value(value: chartConfig),
      ],
      child: Ink(
        color: _chartTheme.base08Color,
        child: GestureManager(
          child: XAxisWrapper(
            maxEpoch: chartDataList.getMaxEpoch(),
            minEpoch: chartDataList.getMinEpoch(),
            entries: widget.mainSeries.input,
            pipSize: widget.pipSize,
            onVisibleAreaChanged: _onVisibleAreaChanged,
            isLive: widget.isLive,
            startWithDataFitMode: widget.dataFitEnabled,
            msPerPx: widget.msPerPx,
            minIntervalWidth: widget.minIntervalWidth,
            maxIntervalWidth: widget.maxIntervalWidth,
            dataFitPadding: widget.dataFitPadding,
            scrollAnimationDuration: currentTickAnimationDuration,
            child: buildChartsLayout(context, overlaySeries, bottomSeries),
          ),
        ),
      ),
    );
  }

  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
  );

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
        oldWidget.bottomConfigs.length != widget.bottomConfigs.length &&
        expandedIndex! < (oldWidget.bottomConfigs.length)) {
      final int? newIndex =
          widget.bottomConfigs.indexOf(oldWidget.bottomConfigs[expandedIndex!]);
      if (newIndex != expandedIndex) {
        expandedIndex = newIndex == -1 ? null : newIndex;
      }
    }
  }
}

class _ChartStateWeb extends _ChartState {
  @override
  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
  ) {
    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    final Duration quoteBoundsAnimationDuration =
        widget.quoteBoundsAnimationDuration ?? _defaultDuration;

    final bool isExpanded = expandedIndex != null;

    return Column(
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
            showLoadingAnimationForHistoricalData: !widget.dataFitEnabled,
            showDataFitButton:
                widget.showDataFitButton ?? widget.dataFitEnabled,
            showScrollToLastTickButton:
                widget.showScrollToLastTickButton ?? true,
            opacity: widget.opacity,
            chartAxisConfig: widget.chartAxisConfig,
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
                pipSize: widget.bottomConfigs[index].pipSize,
                title: widget.bottomConfigs[index].title,
                currentTickAnimationDuration: currentTickAnimationDuration,
                quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
                bottomChartTitleMargin: widget.bottomChartTitleMargin,
                onRemove: () => _onRemove(widget.bottomConfigs[index]),
                onEdit: () => _onEdit(widget.bottomConfigs[index]),
                onExpandToggle: () {
                  setState(() {
                    expandedIndex = expandedIndex != index ? index : null;
                  });
                },
                onSwap: (int offset) => _onSwap(widget.bottomConfigs[index],
                    widget.bottomConfigs[index + offset]),
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
                  widget.bottomConfigs[index],
                ),
                isExpanded: isExpanded,
                showCrosshair: widget.showCrosshair,
                showExpandedIcon: bottomSeries.length > 1,
                showMoveUpIcon:
                    !isExpanded && bottomSeries.length > 1 && index != 0,
                showMoveDownIcon: !isExpanded &&
                    bottomSeries.length > 1 &&
                    index != bottomSeries.length - 1,
              ),
            );
          }).toList()
      ],
    );
  }
}

class _ChartStateMobile extends _ChartState {
  Map<int, bool> _hiddenBottomIndicators = <int, bool>{};

  @override
  void initState() {
    super.initState();
    _hiddenBottomIndicators = Map<int, bool>.fromIterable(
      List<int>.generate(widget.bottomConfigs.length, (int index) => index),
      key: (dynamic index) => index,
      value: (dynamic index) => false,
    );
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.bottomConfigs.length > oldWidget.bottomConfigs.length) {
      for (int i = oldWidget.bottomConfigs.length;
          i < widget.bottomConfigs.length;
          i++) {
        _hiddenBottomIndicators[i] = false;
      }
    }
  }

  @override
  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
  ) {
    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    final Duration quoteBoundsAnimationDuration =
        widget.quoteBoundsAnimationDuration ?? _defaultDuration;

    final bool isExpanded = expandedIndex != null;

    final List<Widget> bottomIndicatorsList =
        bottomSeries!.mapIndexed((int index, Series series) {
      if (isExpanded && expandedIndex != index) {
        return const SizedBox.shrink();
      }

      final Widget bottomChart = BottomChartMobile(
        series: series,
        isHidden: _hiddenBottomIndicators[index] ?? false,
        granularity: widget.granularity,
        pipSize: widget.bottomConfigs[index].pipSize,
        title: '${widget.bottomConfigs[index].displayTitle} '
            '(${widget.bottomConfigs[index].configSummary})',
        currentTickAnimationDuration: currentTickAnimationDuration,
        quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
        bottomChartTitleMargin: const EdgeInsets.only(left: Dimens.margin04),
        onHideUnhideToggle: () {
          setState(() {
            _hiddenBottomIndicators[index] =
                !(_hiddenBottomIndicators[index] ?? false);
          });
        },
        onSwap: (int offset) => _onSwap(
            widget.bottomConfigs[index], widget.bottomConfigs[index + offset]),
        showHideIcon: true,
        showMoveUpIcon: !isExpanded && bottomSeries.length > 1 && index != 0,
        showMoveDownIcon: !isExpanded &&
            bottomSeries.length > 1 &&
            index != bottomSeries.length - 1,
      );

      return (_hiddenBottomIndicators[index] ?? false)
          ? bottomChart
          : Expanded(
              flex: isExpanded ? bottomSeries.length : 1,
              child: bottomChart,
            );
    }).toList();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final double bottomSectionSize =
          1 - (0.65 - 0.125 * (bottomIndicatorsList.length - 1));
      final bool allBottomIndicatorsHidden =
          _hiddenBottomIndicators.values.every((bool value) => value);

      return Column(
        children: <Widget>[
          Expanded(
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
              showLoadingAnimationForHistoricalData: !widget.dataFitEnabled,
              showDataFitButton:
                  widget.showDataFitButton ?? widget.dataFitEnabled,
              showScrollToLastTickButton:
                  widget.showScrollToLastTickButton ?? true,
              opacity: widget.opacity,
              chartAxisConfig: widget.chartAxisConfig,
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
          if (allBottomIndicatorsHidden)
            ...bottomIndicatorsList
          else
            SizedBox(
              height: bottomSectionSize * constraints.maxHeight,
              child: Column(children: bottomIndicatorsList),
            ),
        ],
      );
    });
  }

  @override
  void _onRemove(IndicatorConfig config) {
    final int index = widget.bottomConfigs.indexOf(config);
    _hiddenBottomIndicators.remove(index);

    final Map<int, bool> newMap = <int, bool>{};

    for (int i = 0; i < _hiddenBottomIndicators.values.length; i++) {
      newMap[i] = _hiddenBottomIndicators.values.elementAt(i);
    }

    _hiddenBottomIndicators = newMap;

    super._onRemove(config);
  }

  @override
  void _onSwap(IndicatorConfig config1, IndicatorConfig config2) {
    super._onSwap(config1, config2);

    if (widget.indicatorsRepo != null) {
      final int index1 = widget.bottomConfigs.indexOf(config1);
      final int index2 = widget.bottomConfigs.indexOf(config2);

      // Swap values in hiddenBottomIndicators
      final bool temp = _hiddenBottomIndicators[index1] ?? false;
      _hiddenBottomIndicators[index1] =
          _hiddenBottomIndicators[index2] ?? false;
      _hiddenBottomIndicators[index2] = temp;
    }
  }
}
