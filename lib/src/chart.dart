import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/chart_controller.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'callbacks.dart';
import 'crosshair/crosshair_area.dart';
import 'gestures/gesture_manager.dart';
import 'logic/conversion.dart';
import 'logic/quote_grid.dart';
import 'markers/marker_area.dart';
import 'models/tick.dart';
import 'painters/chart_painter.dart';
import 'painters/loading_painter.dart';
import 'painters/y_grid_painter.dart';
import 'theme/chart_default_dark_theme.dart';
import 'theme/chart_default_light_theme.dart';
import 'theme/chart_theme.dart';
import 'x_axis/x_axis.dart';
import 'x_axis/x_axis_model.dart';

/// Interactive chart widget.
class Chart extends StatelessWidget {
  /// Creates chart that expands to available space.
  const Chart({
    @required this.mainSeries,
    @required this.pipSize,
    @required this.granularity,
    this.controller,
    this.secondarySeries,
    this.markerSeries,
    this.theme,
    this.onCrosshairAppeared,
    this.onVisibleAreaChanged,
    this.isLive = false,
    this.opacity = 1.0,
    this.annotations,
    Key key,
  }) : super(key: key);

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// List of series to add on chart beside the [mainSeries].
  ///
  /// Useful for adding on-chart indicators.
  final List<Series> secondarySeries;

  /// Open position marker series.
  final MarkerSeries markerSeries;

  /// Chart's controller
  final ChartController controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when crosshair details appear after long press.
  final VoidCallback onCrosshairAppeared;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback onVisibleAreaChanged;

  /// Chart's theme.
  final ChartTheme theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>> annotations;

  /// Whether the chart should be showing live data or not.
  ///
  /// In case of being true the chart will keep auto-scrolling when its visible area
  /// is on the newest ticks/candles.
  final bool isLive;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final ChartTheme chartTheme =
        theme ?? Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();

    final ChartConfig chartConfig = ChartConfig(
      pipSize: pipSize,
      granularity: granularity,
    );

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ChartTheme>.value(value: chartTheme),
        Provider<ChartConfig>.value(value: chartConfig),
      ],
      child: ClipRect(
        child: Ink(
          color: chartTheme.base08Color,
          child: GestureManager(
            child: XAxis(
              entries: mainSeries.entries,
              onVisibleAreaChanged: onVisibleAreaChanged,
              isLive: isLive,
              child: _ChartImplementation(
                controller: controller,
                mainSeries: mainSeries,
                chartDataList: <ChartData>[
                  if (secondarySeries != null) ...secondarySeries,
                  if (annotations != null) ...annotations
                ],
                markerSeries: markerSeries,
                pipSize: pipSize,
                onCrosshairAppeared: onCrosshairAppeared,
                isLive: isLive,
                opacity: opacity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartImplementation extends StatefulWidget {
  const _ChartImplementation({
    Key key,
    @required this.mainSeries,
    @required this.pipSize,
    this.markerSeries,
    @required this.isLive,
    this.opacity,
    this.controller,
    this.onCrosshairAppeared,
    this.chartDataList,
  }) : super(key: key);

  final DataSeries<Tick> mainSeries;
  final MarkerSeries markerSeries;

  final List<ChartData> chartDataList;
  final int pipSize;
  final VoidCallback onCrosshairAppeared;
  final ChartController controller;

  final bool isLive;
  final double opacity;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends State<_ChartImplementation>
    with TickerProviderStateMixin {
  /// Width of the area with quote labels on the right.
  double quoteLabelsAreaWidth = 70;

  bool _panStartedOnQuoteLabelsArea = false;

  /// Height of the area with time labels on the bottom.
  final double timeLabelsAreaHeight = 20;

  Size canvasSize;

  /// Fraction of [canvasSize.height - timeLabelsAreaHeight] taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  double verticalPaddingFraction = 0.1;

  /// Duration of quote bounds animated transition.
  final quoteBoundsAnimationDuration = const Duration(milliseconds: 300);

  /// Top quote bound target for animated transition.
  double topBoundQuoteTarget = 60;

  /// Bottom quote bound target for animated transition.
  double bottomBoundQuoteTarget = 30;

  AnimationController _currentTickAnimationController;
  AnimationController _currentTickBlinkingController;
  AnimationController _loadingAnimationController;
  AnimationController _topBoundQuoteAnimationController;
  AnimationController _bottomBoundQuoteAnimationController;

  // TODO(Rustem): move to YAxisModel
  AnimationController _crosshairZoomOutAnimationController;

  Animation _currentTickAnimation;
  Animation _currentTickBlinkAnimation;

  // TODO(Rustem): move to YAxisModel
  Animation _crosshairZoomOutAnimation;

  // TODO(Rustem): remove crosshair related state
  bool _isCrosshairMode = false;

  bool get _isScrollToLastTickAvailable =>
      widget.mainSeries.entries.isNotEmpty &&
      _xAxis.rightBoundEpoch < widget.mainSeries.entries.last.epoch &&
      !_isCrosshairMode;

  double get _topBoundQuote => _topBoundQuoteAnimationController.value;

  double get _bottomBoundQuote => _bottomBoundQuoteAnimationController.value;

  double get _verticalPadding {
    final px =
        verticalPaddingFraction * (canvasSize.height - timeLabelsAreaHeight);
    final minCrosshairVerticalPadding = 80;
    if (px < minCrosshairVerticalPadding)
      return px +
          (minCrosshairVerticalPadding - px) * _crosshairZoomOutAnimation.value;
    else
      return px;
  }

  double get _topPadding => _verticalPadding;

  double get _bottomPadding => _verticalPadding + timeLabelsAreaHeight;

  double get _quotePerPx => quotePerPx(
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        yTopBound: _quoteToCanvasY(_topBoundQuote),
        yBottomBound: _quoteToCanvasY(_bottomBoundQuote),
      );

  GestureManagerState _gestureManager;

  XAxisModel get _xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _setupGestures();

    widget.controller?.onScrollToLastTick = (bool animate) {
      _xAxis.scrollToLastTick(animate: animate);
    };
  }

  @override
  void didUpdateWidget(_ChartImplementation oldChart) {
    super.didUpdateWidget(oldChart);

    _didUpdateChartData(oldChart);

    _onNewTick();

    // TODO(Rustem): recalculate only when price label length has changed
    _recalculateQuoteLabelsAreaWidth();

    if (widget.isLive != oldChart.isLive) {
      _updateBlinkingAnimationStatus();
    }
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

  void _didUpdateChartData(_ChartImplementation oldChart) {
    if (widget.mainSeries.id == oldChart.mainSeries.id) {
      widget.mainSeries.didUpdate(oldChart.mainSeries);
    }

    if (widget.chartDataList != null) {
      for (final ChartData data in widget.chartDataList) {
        final ChartData oldData = oldChart.chartDataList.firstWhere(
          (ChartData d) => d.id == data.id,
          orElse: () => null,
        );

        if (oldData != null) {
          data.didUpdate(oldData);
        }
      }
    }
  }

  // TODO(ramin): We will eventually remove this and use calculated width of the TextPainter
  void _recalculateQuoteLabelsAreaWidth() {
    if (widget.mainSeries.entries.isEmpty) {
      return;
    }

    final label =
        widget.mainSeries.entries.first.quote.toStringAsFixed(widget.pipSize);
    // TODO(Rustem): Get label style from _theme
    quoteLabelsAreaWidth =
        _getRenderedTextWidth(label, TextStyle(fontSize: 12)) + 10;
  }

  // TODO(ramin): We will eventually remove this and use calculated width of the TextPainter
  double _getRenderedTextWidth(String text, TextStyle style) {
    TextSpan textSpan = TextSpan(
      style: style,
      text: text,
    );
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  void dispose() {
    _currentTickAnimationController?.dispose();
    _currentTickBlinkingController?.dispose();
    _loadingAnimationController?.dispose();
    _topBoundQuoteAnimationController?.dispose();
    _bottomBoundQuoteAnimationController?.dispose();
    _crosshairZoomOutAnimationController?.dispose();
    _clearGestures();
    super.dispose();
  }

  void _onNewTick() {
    _currentTickAnimationController.reset();
    _currentTickAnimationController.forward();
  }

  void _setupAnimations() {
    _setupCurrentTickAnimation();
    _setupBlinkingAnimation();
    _setupBoundsAnimation();
    _setupCrosshairZoomOutAnimation();
  }

  void _setupCurrentTickAnimation() {
    _currentTickAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _currentTickAnimation = CurvedAnimation(
      parent: _currentTickAnimationController,
      curve: Curves.easeOut,
    );
  }

  void _setupBlinkingAnimation() {
    _currentTickBlinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _currentTickBlinkingController.repeat(reverse: true);
    _loadingAnimationController.repeat();
    _currentTickBlinkAnimation = CurvedAnimation(
      parent: _currentTickBlinkingController,
      curve: Curves.easeInOut,
    );
  }

  void _setupBoundsAnimation() {
    _topBoundQuoteAnimationController = AnimationController.unbounded(
      value: topBoundQuoteTarget,
      vsync: this,
      duration: quoteBoundsAnimationDuration,
    );
    _bottomBoundQuoteAnimationController = AnimationController.unbounded(
      value: bottomBoundQuoteTarget,
      vsync: this,
      duration: quoteBoundsAnimationDuration,
    );
  }

  void _setupCrosshairZoomOutAnimation() {
    _crosshairZoomOutAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _crosshairZoomOutAnimation = CurvedAnimation(
      parent: _crosshairZoomOutAnimationController,
      curve: Curves.easeOut,
    );
  }

  void _setupGestures() {
    _gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onPanStart)
      ..registerCallback(_onPanUpdate);
  }

  void _clearGestures() {
    _gestureManager..removeCallback(_onPanStart)..removeCallback(_onPanUpdate);
  }

  void _updateChartData() {
    widget.mainSeries.update(_xAxis.leftBoundEpoch, _xAxis.rightBoundEpoch);

    if (widget.chartDataList != null) {
      for (final ChartData data in widget.chartDataList) {
        data.update(_xAxis.leftBoundEpoch, _xAxis.rightBoundEpoch);
      }
    }
  }

  void _updateQuoteBoundTargets() {
    double minQuote = widget.mainSeries.minValue;
    double maxQuote = widget.mainSeries.maxValue;

    if (widget.chartDataList != null) {
      final Iterable<ChartData> dataInAction = widget.chartDataList.where(
        (ChartData chartData) =>
            !chartData.minValue.isNaN && !chartData.maxValue.isNaN,
      );

      if (dataInAction.isNotEmpty) {
        final double chartDataMin = dataInAction
            .map((ChartData chartData) => chartData.minValue)
            .reduce(min);
        final double chartDataMax = dataInAction
            .map((ChartData chartData) => chartData.maxValue)
            .reduce(max);

        minQuote = min(widget.mainSeries.minValue, chartDataMin);
        maxQuote = max(widget.mainSeries.maxValue, chartDataMax);
      }
    }

    if (!minQuote.isNaN && minQuote != bottomBoundQuoteTarget) {
      bottomBoundQuoteTarget = minQuote;
      _bottomBoundQuoteAnimationController.animateTo(
        bottomBoundQuoteTarget,
        curve: Curves.easeOut,
      );
    }
    if (!maxQuote.isNaN && maxQuote != topBoundQuoteTarget) {
      topBoundQuoteTarget = maxQuote;
      _topBoundQuoteAnimationController.animateTo(
        topBoundQuoteTarget,
        curve: Curves.easeOut,
      );
    }
  }

  double _quoteToCanvasY(double quote) => quoteToCanvasY(
        quote: quote,
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        canvasHeight: canvasSize.height,
        topPadding: _topPadding,
        bottomPadding: _bottomPadding,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      canvasSize = Size(
        context.watch<XAxisModel>().width,
        constraints.maxHeight,
      );

      _updateChartData();
      _updateQuoteBoundTargets();

      return Stack(
        children: <Widget>[
          CustomPaint(
            size: canvasSize,
            painter: YGridPainter(
              gridLineQuotes: _getGridLineQuotes(),
              pipSize: widget.pipSize,
              quoteLabelsAreaWidth: quoteLabelsAreaWidth,
              quoteToCanvasY: _quoteToCanvasY,
              style: context.watch<ChartTheme>().gridStyle,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: LoadingPainter(
              loadingAnimationProgress: _loadingAnimationController.value,
              loadingRightBoundX: widget.mainSeries.visibleEntries.isEmpty
                  ? _xAxis.width
                  : _xAxis.xFromEpoch(
                      widget.mainSeries.visibleEntries.first.epoch,
                    ),
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          Opacity(
            opacity: widget.opacity,
            child: CustomPaint(
              size: canvasSize,
              painter: ChartPainter(
                animationInfo: AnimationInfo(
                  currentTickPercent: _currentTickAnimation.value,
                  blinkingPercent: _currentTickBlinkAnimation.value,
                ),
                chartDataList: <ChartData>[
                  widget.mainSeries,
                ],
                chartConfig: _xAxis.chartConfig,
                theme: context.read<ChartTheme>(),
                epochToCanvasX: _xAxis.xFromEpoch,
                quoteToCanvasY: _quoteToCanvasY,
              ),
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: ChartPainter(
              animationInfo: AnimationInfo(
                currentTickPercent: _currentTickAnimation.value,
                blinkingPercent: _currentTickBlinkAnimation.value,
              ),
              chartDataList: <ChartData>[
                if (widget.chartDataList != null) ...widget.chartDataList
              ],
              chartConfig: _xAxis.chartConfig,
              theme: context.read<ChartTheme>(),
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          if (widget.markerSeries != null)
            MarkerArea(
              markerSeries: widget.markerSeries,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          CrosshairArea(
            mainSeries: widget.mainSeries,
            pipSize: widget.pipSize,
            quoteToCanvasY: _quoteToCanvasY,
            onCrosshairAppeared: () {
              _isCrosshairMode = true;
              widget.onCrosshairAppeared?.call();
              _crosshairZoomOutAnimationController.forward();
            },
            onCrosshairDisappeared: () {
              _isCrosshairMode = false;
              _crosshairZoomOutAnimationController.reverse();
            },
          ),
          if (_isScrollToLastTickAvailable)
            Positioned(
              bottom: 30 + timeLabelsAreaHeight,
              right: 30 + quoteLabelsAreaWidth,
              child: _buildScrollToLastTickButton(),
            ),
        ],
      );
    });
  }

  List<double> _getGridLineQuotes() {
    return gridQuotes(
      quoteGridInterval: quoteGridInterval(_quotePerPx),
      topBoundQuote: _topBoundQuote,
      bottomBoundQuote: _bottomBoundQuote,
      canvasHeight: canvasSize.height,
      topPadding: _topPadding,
      bottomPadding: _bottomPadding,
    );
  }

  void _onPanStart(ScaleStartDetails details) {
    _panStartedOnQuoteLabelsArea = _onQuoteLabelsArea(details.localFocalPoint);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartedOnQuoteLabelsArea &&
        _onQuoteLabelsArea(details.localPosition)) {
      _scaleVertically(details.delta.dy);
    }
  }

  bool _onQuoteLabelsArea(Offset position) =>
      position.dx > _xAxis.width - quoteLabelsAreaWidth;

  void _scaleVertically(double dy) {
    setState(() {
      verticalPaddingFraction =
          ((_verticalPadding + dy) / (canvasSize.height - timeLabelsAreaHeight))
              .clamp(0.05, 0.49);
    });
  }

  IconButton _buildScrollToLastTickButton() {
    return IconButton(
      icon: Icon(Icons.arrow_forward, color: Colors.white),
      onPressed: _xAxis.scrollToLastTick,
    );
  }
}
