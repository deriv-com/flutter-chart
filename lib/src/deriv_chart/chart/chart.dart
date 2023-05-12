import 'package:collection/collection.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'bottom_chart.dart';
import 'data_visualization/chart_data.dart';
import 'main_chart.dart';

/// Interactive chart widget.
class Chart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const Chart({
    required this.mainSeries,
    required this.granularity,
    required this.onAddDrawing,
    this.drawings,
    this.selectedDrawingTool,
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

  /// Existing drawings.
  final List<DrawingData>? drawings;

  /// Callback to pass new drawing to the parent.
  final void Function(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

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

  /// Max distance between rightBoundEpoch and nowEpoch in pixels.
  final double? maxCurrentTickOffset;

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

    final bool isExpanded = expandedIndex != null;

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
            dataFitMode: widget.dataFitEnabled,
            maxCurrentTickOffset: widget.maxCurrentTickOffset,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: MainChart(
                    drawings: widget.drawings,
                    onAddDrawing: widget.onAddDrawing,
                    selectedDrawingTool: widget.selectedDrawingTool,
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
                    showDataFitButton: widget.dataFitEnabled,
                    opacity: widget.opacity,
                    showCrosshair: widget.showCrosshair,
                    onCrosshairDisappeared: widget.onCrosshairDisappeared,
                    onCrosshairHover: widget.onCrosshairHover,
                  ),
                ),
                if (bottomSeries?.isNotEmpty ?? false)
                  ...bottomSeries!.mapIndexed((int index, Series series) {
                    if (isExpanded && expandedIndex != index) {
                      return Container();
                    }

                    return Expanded(
                      flex: isExpanded ? bottomSeries.length : 1,
                      child: BottomChart(
                        series: series,
                        pipSize: widget.pipSize,
                        title: widget.bottomConfigs![index].title,
                        onRemove: () {
                          expandedIndex = null;
                          widget.indicatorsRepo
                              ?.remove(widget.bottomConfigs![index]);
                        },
                        onEdit: () {
                          widget.indicatorsRepo?.edit(
                            widget.bottomConfigs![index],
                          );
                        },
                        onExpandToggle: () {
                          expandedIndex = expandedIndex != index ? index : null;
                        },
                        onSwap: (int offset) {
                          _onSwap(widget.bottomConfigs![index],
                              widget.bottomConfigs![index + offset]);
                        },
                        onCrosshairDisappeared: widget.onCrosshairDisappeared,
                        onCrosshairHover: widget.onCrosshairHover,
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
        _controller.onScrollToLastTick?.call(false);
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
        _controller.onScrollToLastTick?.call(false);
      }
    }
  }
}
