import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'bottom_chart.dart';
import 'data_visualization/chart_data.dart';
import 'main_chart.dart';

/// Interactive chart widget.
class Chart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const Chart({
    required this.mainSeries,
    required this.granularity,
    required this.drawingTools,
    this.pipSize = 4,
    this.controller,
    this.overlaySeries,
    this.bottomSeries,
    this.markerSeries,
    this.theme,
    this.onCrosshairAppeared,
    this.onVisibleAreaChanged,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.opacity = 1.0,
    this.annotations,
    this.chartAxisConfig = const ChartAxisConfig(),
    Key? key,
  }) : super(key: key);

  /// Chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// List of overlay indicator series to add on chart beside the [mainSeries].
  final List<Series>? overlaySeries;

  /// List of bottom indicator series to add on chart separate from the
  /// [mainSeries].
  final List<Series>? bottomSeries;

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

  /// Configurations for chart's axes.
  final ChartAxisConfig chartAxisConfig;

  @override
  State<StatefulWidget> createState() => _ChartState();
}

// ignore: prefer_mixin
class _ChartState extends State<Chart> with WidgetsBindingObserver {
  bool? _followCurrentTick;
  late ChartController _controller;
  late ChartTheme _chartTheme;

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
      chartAxisConfig: widget.chartAxisConfig,
    );

    final List<ChartData> chartDataList = <ChartData>[
      widget.mainSeries,
      if (widget.overlaySeries != null) ...widget.overlaySeries!,
      if (widget.bottomSeries != null) ...widget.bottomSeries!,
      if (widget.annotations != null) ...widget.annotations!,
    ];

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
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: MainChart(
                    drawingTools: widget.drawingTools,
                    controller: _controller,
                    mainSeries: widget.mainSeries,
                    overlaySeries: widget.overlaySeries,
                    annotations: widget.annotations,
                    markerSeries: widget.markerSeries,
                    pipSize: widget.pipSize,
                    onCrosshairAppeared: widget.onCrosshairAppeared,
                    isLive: widget.isLive,
                    showLoadingAnimationForHistoricalData:
                        !widget.dataFitEnabled,
                    showDataFitButton: widget.dataFitEnabled,
                    opacity: widget.opacity,
                    chartAxisConfig: widget.chartAxisConfig,
                  ),
                ),
                if (widget.bottomSeries?.isNotEmpty ?? false)
                  ...widget.bottomSeries!
                      .map((Series series) => Expanded(
                              child: BottomChart(
                            series: series,
                            pipSize: widget.pipSize,
                          )))
                      .toList()
              ],
            ),
          ),
        ),
      ),
    );
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
  }
}
