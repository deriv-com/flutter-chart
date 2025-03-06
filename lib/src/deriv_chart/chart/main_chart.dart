import 'package:collection/collection.dart' show IterableExtension;
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/misc/chart_controller.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/crosshair_area_web.dart';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/crosshair_area.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_data_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_area.dart';
import 'package:deriv_chart/src/deriv_chart/chart/loading_animation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'basic_chart.dart';
import 'multiple_animated_builder.dart';
import 'data_visualization/annotations/chart_annotation.dart';
import 'data_visualization/chart_data.dart';
import 'data_visualization/chart_series/data_series.dart';
import 'data_visualization/chart_series/series.dart';
import 'data_visualization/markers/marker_series.dart';
import 'data_visualization/models/animation_info.dart';
import 'data_visualization/models/chart_object.dart';
import 'helpers/functions/helper_functions.dart';
import '../../misc/callbacks.dart';
import '../../theme/chart_theme.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tool_chart.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';

/// The main chart to display in the chart widget.
class MainChart extends BasicChart {
  /// Initializes the main chart to display in the chart widget.
  MainChart({
    required DataSeries<Tick> mainSeries,
    this.drawingTools,
    this.isLive = false,
    int pipSize = 4,
    Key? key,
    this.showLoadingAnimationForHistoricalData = true,
    this.showDataFitButton = false,
    this.showScrollToLastTickButton = true,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.overlaySeries,
    this.annotations,
    this.verticalPaddingFraction,
    this.loadingAnimationColor,
    this.showCurrentTickBlinkAnimation = true,
    super.currentTickAnimationDuration,
    super.quoteBoundsAnimationDuration,
    double opacity = 1,
    ChartAxisConfig? chartAxisConfig,
    VisibleQuoteAreaChangedCallback? onQuoteAreaChanged,
    this.showCrosshair = false,
  })  : _mainSeries = mainSeries,
        chartDataList = <ChartData>[
          mainSeries,
          if (overlaySeries != null) ...overlaySeries,
          if (annotations != null) ...annotations,
        ],
        super(
          key: key,
          mainSeries: mainSeries,
          pipSize: pipSize,
          opacity: opacity,
          chartAxisConfig: chartAxisConfig,
          onQuoteAreaChanged: onQuoteAreaChanged,
        );

  /// The indicator series that are displayed on the main chart.
  final List<Series>? overlaySeries;
  final DataSeries<Tick> _mainSeries;

  /// List of chart annotations used in the chart.
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// The series that hold the list markers.
  final MarkerSeries? markerSeries;

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools? drawingTools;

  /// The function that gets called on crosshair appearance.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHover? onCrosshairHover;

  /// Chart's widget controller.
  final ChartController? controller;

  /// Whether the widget is live or not.
  final bool isLive;

  /// Whether the widget is showing loading animation or not.
  final bool showLoadingAnimationForHistoricalData;

  /// Whether to show the data fit button or not.
  final bool showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool showScrollToLastTickButton;

  /// Convenience list to access all chart data.
  final List<ChartData> chartDataList;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  final double? verticalPaddingFraction;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  /// Whether to show current tick blink animation or not.
  final bool showCurrentTickBlinkAnimation;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends BasicChartState<MainChart> {
  /// Padding should be at least half of barrier label height.

  late AnimationController _currentTickBlinkingController;

  late Animation<double> _currentTickBlinkAnimation;

  // TODO(Rustem): remove crosshair related state
  bool _isCrosshairMode = false;

  bool get _isScrollToLastTickAvailable =>
      (widget._mainSeries.entries?.isNotEmpty ?? false) &&
      xAxis.rightBoundEpoch < widget._mainSeries.entries!.last.epoch &&
      !_isCrosshairMode;

  /// Crosshair related state.
  late AnimationController crosshairZoomOutAnimationController;

  /// The current animation value of crosshair zoom out.
  late Animation<double> crosshairZoomOutAnimation;

  @override
  double get verticalPadding {
    if (canvasSize == null) {
      return 0;
    }

    final double padding = verticalPaddingFraction * canvasSize!.height;
    const double minCrosshairPadding = 80;
    final double paddingValue = padding +
        (minCrosshairPadding - padding).clamp(0, minCrosshairPadding) *
            crosshairZoomOutAnimation.value;
    if (BasicChartState.minPadding < canvasSize!.height / 2) {
      return paddingValue.clamp(
          BasicChartState.minPadding, canvasSize!.height / 2);
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.verticalPaddingFraction != null) {
      verticalPaddingFraction = widget.verticalPaddingFraction!;
    }

    _setupController();
  }

  @override
  void didUpdateWidget(MainChart oldChart) {
    super.didUpdateWidget(oldChart);

    didUpdateChartData(oldChart);

    if (widget.isLive != oldChart.isLive ||
        widget.showCurrentTickBlinkAnimation !=
            oldChart.showCurrentTickBlinkAnimation) {
      _updateBlinkingAnimationStatus();
    }

    xAxis.update(
      minEpoch: widget.chartDataList.getMinEpoch(),
      maxEpoch: widget.chartDataList.getMaxEpoch(),
    );
  }

  void _updateBlinkingAnimationStatus() {
    if (widget.isLive && widget.showCurrentTickBlinkAnimation) {
      _currentTickBlinkingController.repeat(reverse: true);
    } else {
      _currentTickBlinkingController
        ..reset()
        ..stop();
    }
  }

  @override
  void didUpdateChartData(covariant MainChart oldChart) {
    super.didUpdateChartData(oldChart);
    for (final ChartData data in widget.chartDataList.where(
      // Exclude mainSeries, since its didUpdate is already called
      (ChartData d) => d.id != widget.mainSeries.id,
    )) {
      final ChartData? oldData = oldChart.chartDataList.firstWhereOrNull(
        (ChartData d) => d.id == data.id,
      );

      data.didUpdate(oldData);
    }
  }

  @override
  void dispose() {
    _currentTickBlinkingController.dispose();
    crosshairZoomOutAnimationController.dispose();
    super.dispose();
  }

  @override
  void setupAnimations() {
    super.setupAnimations();
    _setupBlinkingAnimation();
    _setupCrosshairZoomOutAnimation();
  }

  void _setupController() {
    widget.controller?.onScrollToLastTick = ({required bool animate}) {
      if (mounted) {
        // TODO(Ramin): add the ability to close the controller.
        xAxis.scrollToLastTick(animate: animate);
      }
    };

    widget.controller?.onScale = (double scale) {
      xAxis
        ..onScaleAndPanStart(ScaleStartDetails())
        ..onScaleUpdate(ScaleUpdateDetails(scale: scale));
      return xAxis.msPerPx;
    };

    widget.controller?.onScroll = (double pxShift) {
      xAxis.scrollBy(pxShift);
    };

    widget.controller?.toggleXScrollBlock = ({required bool isXScrollBlocked}) {
      xAxis.isScrollBlocked = isXScrollBlocked;
    };

    widget.controller?.toggleDataFitMode = ({required bool enableDataFit}) {
      if (enableDataFit) {
        xAxis.enableDataFit();
      } else {
        xAxis.disableDataFit();
      }
    };

    widget.controller?.getXFromEpoch = (int epoch) => xAxis.xFromEpoch(epoch);
    widget.controller?.getYFromQuote =
        (double quote) => chartQuoteToCanvasY(quote);

    widget.controller?.getEpochFromX = (double x) => xAxis.epochFromX(x);
    widget.controller?.getQuoteFromY = (double y) => chartQuoteFromCanvasY(y);

    widget.controller?.getMsPerPx = () => xAxis.msPerPx;
  }

  void _setupCrosshairZoomOutAnimation() {
    crosshairZoomOutAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    crosshairZoomOutAnimation = CurvedAnimation(
      parent: crosshairZoomOutAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  List<Listenable> getQuoteGridAnimations() =>
      super.getQuoteGridAnimations()..add(crosshairZoomOutAnimation);

  @override
  List<Listenable> getQuoteLabelAnimations() =>
      super.getQuoteLabelAnimations()..add(crosshairZoomOutAnimation);

  @override
  List<Listenable> getChartDataAnimations() =>
      super.getChartDataAnimations()..add(crosshairZoomOutAnimation);

  void _setupBlinkingAnimation() {
    _currentTickBlinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _currentTickBlinkAnimation = CurvedAnimation(
      parent: _currentTickBlinkingController,
      curve: Curves.easeInOut,
    );

    if (widget.showCurrentTickBlinkAnimation) {
      _currentTickBlinkingController.repeat(reverse: true);
    }
  }

  @override
  void updateVisibleData() {
    super.updateVisibleData();

    for (final ChartData data in widget.chartDataList) {
      data.update(xAxis.leftBoundEpoch, xAxis.rightBoundEpoch);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final XAxisModel xAxis = context.watch<XAxisModel>();

          canvasSize = Size(
            xAxis.width!,
            constraints.maxHeight,
          );

          updateVisibleData();
          // TODO(mohammadamir-fs): Remove Extra ClipRect.
          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // _buildQuoteGridLine(gridLineQuotes),

                if (widget.showLoadingAnimationForHistoricalData ||
                    (widget._mainSeries.entries?.isEmpty ?? false))
                  _buildLoadingAnimation(),
                // _buildQuoteGridLabel(gridLineQuotes),
                super.build(context),
                if (widget.overlaySeries != null)
                  _buildSeries(widget.overlaySeries!),
                _buildAnnotations(),
                if (widget.markerSeries != null) _buildMarkerArea(),
                if (widget.drawingTools != null)
                  _buildDrawingToolChart(widget.drawingTools!),
                if (kIsWeb) _buildCrosshairAreaWeb(),
                if (!kIsWeb && !(widget.drawingTools?.isDrawingMoving ?? false))
                  _buildCrosshairArea(),
                if (widget.showScrollToLastTickButton &&
                    _isScrollToLastTickAvailable)
                  Positioned(
                    bottom: 0,
                    right: quoteLabelsTouchAreaWidth,
                    child: _buildScrollToLastTickButton(),
                  ),
                if (widget.showDataFitButton &&
                    (widget._mainSeries.entries?.isNotEmpty ?? false))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildDataFitButton(),
                  ),
              ],
            ),
          );
        },
      );

  Widget _buildDrawingToolChart(DrawingTools drawingTools) =>
      MultipleAnimatedBuilder(
        animations: <Listenable>[
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
        ],
        builder: (_, Widget? child) => DrawingToolChart(
          series: widget.mainSeries as DataSeries<Tick>,
          chartQuoteToCanvasY: chartQuoteToCanvasY,
          chartQuoteFromCanvasY: chartQuoteFromCanvasY,
          drawingTools: drawingTools,
        ),
      );

  Widget _buildLoadingAnimation() => LoadingAnimationArea(
        loadingRightBoundX: widget._mainSeries.input.isEmpty
            ? xAxis.width!
            : xAxis.xFromEpoch(widget._mainSeries.input.first.epoch),
        loadingAnimationColor: widget.loadingAnimationColor,
      );

  Widget _buildAnnotations() => MultipleAnimatedBuilder(
        animations: <Animation<double>>[
          currentTickAnimation,
          _currentTickBlinkAnimation,
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
        ],
        builder: (BuildContext context, _) =>
            Stack(fit: StackFit.expand, children: <Widget>[
          if (widget.annotations != null)
            ...widget.annotations!
                .map(
                  (ChartData annotation) => RepaintBoundary(
                    child: CustomPaint(
                      key: ValueKey<String>(annotation.id),
                      painter: ChartPainter(
                        animationInfo: AnimationInfo(
                          currentTickPercent: currentTickAnimation.value,
                          blinkingPercent: _currentTickBlinkAnimation.value,
                        ),
                        chartData: annotation,
                        chartConfig: context.watch<ChartConfig>(),
                        theme: context.watch<ChartTheme>(),
                        epochToCanvasX: xAxis.xFromEpoch,
                        quoteToCanvasY: chartQuoteToCanvasY,
                        chartScaleModel: context.watch<ChartScaleModel>(),
                      ),
                    ),
                  ),
                )
                .toList()
        ]),
      );

  Widget _buildCrosshairArea() => AnimatedBuilder(
        animation: crosshairZoomOutAnimation,
        builder: (BuildContext context, _) => CrosshairArea(
          mainSeries: widget.mainSeries as DataSeries<Tick>,
          pipSize: widget.pipSize,
          quoteToCanvasY: chartQuoteToCanvasY,
          onCrosshairAppeared: () {
            _isCrosshairMode = true;
            widget.onCrosshairAppeared?.call();
            crosshairZoomOutAnimationController.forward();
          },
          onCrosshairDisappeared: () {
            _isCrosshairMode = false;
            crosshairZoomOutAnimationController.reverse();
          },
        ),
      );

  Widget _buildCrosshairAreaWeb() => CrosshairAreaWeb(
        mainSeries: widget.mainSeries as DataSeries<Tick>,
        epochFromCanvasX: xAxis.epochFromX,
        quoteFromCanvasY: chartQuoteFromCanvasY,
        epochToCanvasX: xAxis.xFromEpoch,
        quoteToCanvasY: chartQuoteToCanvasY,
        quoteLabelsTouchAreaWidth: quoteLabelsTouchAreaWidth,
        showCrosshairCursor: widget.showCrosshair,
        onCrosshairDisappeared: widget.onCrosshairDisappeared,
        onCrosshairHover: widget.onCrosshairHover,
      );

  Widget _buildScrollToLastTickButton() => Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: xAxis.scrollToLastTick,
          color: context.read<ChartTheme>().base01Color,
        ),
      );

  // Main series and indicators on top of main series.
  Widget _buildSeries(List<Series> series) => MultipleAnimatedBuilder(
        animations: <Listenable>[
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
          crosshairZoomOutAnimation,
        ],
        builder: (BuildContext context, Widget? child) => RepaintBoundary(
          child: CustomPaint(
            painter: BaseChartDataPainter(
              animationInfo: AnimationInfo(
                currentTickPercent: currentTickAnimation.value,
              ),
              series: series,
              chartConfig: context.watch<ChartConfig>(),
              theme: context.watch<ChartTheme>(),
              epochToCanvasX: xAxis.xFromEpoch,
              quoteToCanvasY: chartQuoteToCanvasY,
              rightBoundEpoch: xAxis.rightBoundEpoch,
              leftBoundEpoch: xAxis.leftBoundEpoch,
              topY: chartQuoteToCanvasY(widget.mainSeries.maxValue),
              bottomY: chartQuoteToCanvasY(widget.mainSeries.minValue),
              chartScaleModel: context.watch<ChartScaleModel>(),
            ),
          ),
        ),
      );

  Widget _buildMarkerArea() => MultipleAnimatedBuilder(
        animations: <Listenable>[
          currentTickAnimation,
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController
        ],
        builder: (BuildContext context, _) => MarkerArea(
          markerSeries: widget.markerSeries!,
          quoteToCanvasY: chartQuoteToCanvasY,
        ),
      );

  Widget _buildDataFitButton() {
    final XAxisModel xAxis = context.read<XAxisModel>();
    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: const Icon(Icons.fullscreen_exit),
        onPressed: xAxis.dataFitEnabled ? null : xAxis.enableDataFit,
      ),
    );
  }

  @override
  List<double> getSeriesMinMaxValue() {
    final List<double> minMaxValues = super.getSeriesMinMaxValue();
    double minQuote = minMaxValues[0];
    double maxQuote = minMaxValues[1];

    minQuote = safeMin(minQuote, widget.chartDataList.getMinValue());
    maxQuote = safeMax(maxQuote, widget.chartDataList.getMaxValue());
    return <double>[minQuote, maxQuote];
  }
}
