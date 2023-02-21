import 'package:collection/collection.dart' show IterableExtension;
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/crosshair_area.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_data_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_area.dart';
import 'package:deriv_chart/src/deriv_chart/chart/loading_animation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'basic_chart.dart';
import 'data_visualization/chart_data.dart';
import 'data_visualization/models/animation_info.dart';
import 'helpers/functions/helper_functions.dart';
import 'multiple_animated_builder.dart';

/// The main chart to display in the chart widget.
class MainChart extends BasicChart {
  /// Initializes the main chart to display in the chart widget.
  MainChart({
    required DataSeries<Tick> mainSeries,
    required this.onAddDrawing,
    this.drawings,
    this.selectedDrawingTool,
    this.isLive = false,
    int pipSize = 4,
    Key? key,
    this.showLoadingAnimationForHistoricalData = true,
    this.showDataFitButton = false,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.overlaySeries,
    this.annotations,
    double opacity = 1,
    ChartAxisConfig? chartAxisConfig,
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
        );

  /// The indicator series that are displayed on the main chart.
  final List<Series>? overlaySeries;
  final DataSeries<Tick> _mainSeries;

  /// List of chart annotations used in the chart.
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// The series that hold the list markers.
  final MarkerSeries? markerSeries;

  /// Existing drawings.
  final List<DrawingData>? drawings;

  /// Callback to pass new drawing to the parent.
  final void Function(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

  /// The function that gets called on crosshair appearance.
  final VoidCallback? onCrosshairAppeared;

  /// Chart's widget controller.
  final ChartController? controller;

  /// Whether the widget is live or not.
  final bool isLive;

  /// Whether the widget is showing loading animation or not.
  final bool showLoadingAnimationForHistoricalData;

  /// Whether to show the data fit button or not.
  final bool showDataFitButton;

  /// Convenience list to access all chart data.
  final List<ChartData> chartDataList;

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

    widget.controller?.onScrollToLastTick = ({required bool animate}) {
      if (mounted) {
        // TODO(Ramin): add the ability to close the controller.
        xAxis.scrollToLastTick(animate: animate);
      }
    };
  }

  @override
  void didUpdateWidget(MainChart oldChart) {
    super.didUpdateWidget(oldChart);

    didUpdateChartData(oldChart);

    if (widget.isLive != oldChart.isLive) {
      _updateBlinkingAnimationStatus();
    }

    xAxis.update(
      minEpoch: widget.chartDataList.getMinEpoch(),
      maxEpoch: widget.chartDataList.getMaxEpoch(),
    );
  }

  void _updateBlinkingAnimationStatus() {
    if (widget.isLive) {
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
    )..repeat(reverse: true);

    _currentTickBlinkAnimation = CurvedAnimation(
      parent: _currentTickBlinkingController,
      curve: Curves.easeInOut,
    );
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
                _buildSeries(),
                _buildAnnotations(),
                if (widget.markerSeries != null)
                  MultipleAnimatedBuilder(
                    animations: <Listenable>[
                      currentTickAnimation,
                      topBoundQuoteAnimationController,
                      bottomBoundQuoteAnimationController,
                    ],
                    builder: (_, __) => MarkerArea(
                      markerSeries: widget.markerSeries!,
                      quoteToCanvasY: chartQuoteToCanvasY,
                    ),
                  ),
                if (widget.drawings != null)
                  ...widget.drawings!
                      .map((DrawingData drawingData) => DrawingPainter(
                            drawingData: drawingData,
                            quoteToCanvasY: chartQuoteToCanvasY,
                          )),
                if (widget.selectedDrawingTool != null)
                  DrawingCreator(
                    onAddDrawing: widget.onAddDrawing,
                    selectedDrawingTool: widget.selectedDrawingTool!,
                    quoteFromCanvasY: chartQuoteFromCanvasY,
                  ),
                _buildCrosshairArea(),
                if (_isScrollToLastTickAvailable)
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

  Widget _buildLoadingAnimation() => LoadingAnimationArea(
        loadingRightBoundX: widget._mainSeries.input.isEmpty
            ? xAxis.width!
            : xAxis.xFromEpoch(widget._mainSeries.input.first.epoch),
      );

  Widget _buildAnnotations() => MultipleAnimatedBuilder(
        animations: <Animation<double>>[
          currentTickAnimation,
          _currentTickBlinkAnimation,
        ],
        builder: (BuildContext context, _) =>
            Stack(fit: StackFit.expand, children: <Widget>[
          if (widget.annotations != null)
            ...widget.annotations!
                .map((ChartData annotation) => CustomPaint(
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
                      ),
                    ))
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

  Widget _buildScrollToLastTickButton() => Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: xAxis.scrollToLastTick,
        ),
      );

  // Main series and indicators on top of main series.
  Widget _buildSeries() => MultipleAnimatedBuilder(
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
              series: widget.overlaySeries!,
              chartConfig: context.watch<ChartConfig>(),
              theme: context.watch<ChartTheme>(),
              epochToCanvasX: xAxis.xFromEpoch,
              quoteToCanvasY: chartQuoteToCanvasY,
              rightBoundEpoch: xAxis.rightBoundEpoch,
              leftBoundEpoch: xAxis.leftBoundEpoch,
              topY: chartQuoteToCanvasY(widget.mainSeries.maxValue),
              bottomY: chartQuoteToCanvasY(widget.mainSeries.minValue),
            ),
          ),
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
