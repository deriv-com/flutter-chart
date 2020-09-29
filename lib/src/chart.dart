import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/src/chart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'callbacks.dart';
import 'crosshair/crosshair_area.dart';
import 'gestures/gesture_manager.dart';
import 'logic/conversion.dart';
import 'logic/quote_grid.dart';
import 'models/candle.dart';
import 'models/chart_style.dart';
import 'models/tick.dart';
import 'painters/chart_painter.dart';
import 'painters/current_tick_painter.dart';
import 'painters/loading_painter.dart';
import 'painters/y_grid_painter.dart';
import 'theme/chart_default_dark_theme.dart';
import 'theme/chart_default_light_theme.dart';
import 'theme/chart_theme.dart';
import 'theme/painting_styles/chart_paiting_style.dart';
import 'x_axis/x_axis.dart';
import 'x_axis/x_axis_model.dart';

/// Interactive chart widget.
class Chart extends StatelessWidget {
  /// Creates chart that expands to available space.
  const Chart({
    @required this.candles,
    @required this.pipSize,
    @required this.granularity,
    this.controller,
    this.theme,
    this.onCrosshairAppeared,
    this.onLoadHistory,
    this.style = ChartStyle.candles,
    this.isLive,
    Key key,
  }) : super(key: key);

  /// Sorted list of all candles (including those outside bounds).
  /// Use [Candle.tick] constructor to represent ticks.
  ///
  /// Super class for ticks and candles wasn't used to avoid complicating things.
  /// If you are going to refactor it, consider these features:
  /// - switching between chart styles
  /// - disabling candle style for ticks
  final List<Candle> candles;

  /// Chart's controller
  final ChartController controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// The chart type that is used to paint [candles].
  final ChartStyle style;

  /// Called when crosshair details appear after long press.
  final VoidCallback onCrosshairAppeared;

  /// Called when chart is scrolled back and missing data is visible.
  final OnLoadHistory onLoadHistory;

  /// Chart's theme.
  final ChartTheme theme;

  /// Indicates whether the chart should be showing live data or not,
  ///
  /// In cas of being true the chart will keep auto-scrolling when its visible area
  /// is on the newest ticks/candles.
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final ChartTheme chartTheme =
        theme ?? Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();

    return Provider<ChartTheme>.value(
      value: chartTheme,
      child: Ink(
        color: chartTheme.base08Color,
        child: GestureManager(
          child: XAxis(
            candles: candles,
            granularity: granularity,
            isLive: isLive,
            child: _ChartImplementation(
              controller: controller,
              candles: candles,
              pipSize: pipSize,
              onCrosshairAppeared: onCrosshairAppeared,
              onLoadHistory: onLoadHistory,
              style: style,
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
    @required this.candles,
    @required this.pipSize,
    this.controller,
    this.onCrosshairAppeared,
    this.onLoadHistory,
    this.style = ChartStyle.candles,
    this.isLive,
  }) : super(key: key);

  final List<Candle> candles;
  final int pipSize;
  final ChartStyle style;
  final VoidCallback onCrosshairAppeared;
  final OnLoadHistory onLoadHistory;
  final ChartController controller;
  final bool isLive;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends State<_ChartImplementation>
    with TickerProviderStateMixin {
  Ticker ticker;

  ChartPaintingStyle _chartPaintingStyle;

  /// Width of the area with quote labels on the right.
  double quoteLabelsAreaWidth = 70;

  bool _panStartedOnQuoteLabelsArea = false;

  /// Height of the area with time labels on the bottom.
  final double timeLabelsAreaHeight = 20;

  List<Candle> visibleCandles = [];

  int requestedLeftEpoch;
  Size canvasSize;
  Tick prevTick;

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

  bool get _isScrollToNowAvailable =>
      widget.candles.isNotEmpty && !_xAxis.animatingPan && !_isCrosshairMode;

  bool get _shouldLoadMoreHistory {
    if (widget.candles.isEmpty) return false;

    final waitingForHistory = requestedLeftEpoch != null &&
        requestedLeftEpoch <= _xAxis.leftBoundEpoch;

    return !waitingForHistory &&
        _xAxis.leftBoundEpoch < widget.candles.first.epoch;
  }

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

  GestureManagerState get _gestureManager =>
      context.read<GestureManagerState>();

  ChartTheme get _theme => context.read<ChartTheme>();

  XAxisModel get _xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();

    ticker = createTicker(_onNewFrame)..start();

    _setChartPaintingStyle();
    _setupAnimations();
    _setupGestures();

    widget.controller?.scrollToNowListener = (bool jump) {
      _xAxis.scrollToNow(jump: jump);
    };
  }

  @override
  void didUpdateWidget(_ChartImplementation oldChart) {
    super.didUpdateWidget(oldChart);

    if (oldChart == null || widget.style != oldChart.style) {
      _setChartPaintingStyle();
    }

    if (widget.candles.isEmpty || oldChart.candles == widget.candles) return;

    if (oldChart.candles.isNotEmpty) {
      prevTick = _candleToTick(oldChart.candles.last);
      _onNewTick();
    }

    // TODO(Rustem): recalculate only when price label length has changed
    _recalculateQuoteLabelsAreaWidth();
  }

  void _recalculateQuoteLabelsAreaWidth() {
    final label = widget.candles.first.close.toStringAsFixed(widget.pipSize);
    // TODO(Rustem): Get label style from _theme
    quoteLabelsAreaWidth =
        _getRenderedTextWidth(label, TextStyle(fontSize: 12)) + 10;
  }

  // TODO(Rustem): Extract this helper function
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

  void _setChartPaintingStyle() =>
      _chartPaintingStyle = widget.style == ChartStyle.candles
          ? _theme.candleStyle
          : _theme.lineStyle;

  @override
  void dispose() {
    ticker?.dispose();
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

  void _onNewFrame(Duration elapsed) {
    if (_shouldLoadMoreHistory) _loadMoreHistory();
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
    _gestureManager
      ..registerCallback(_onPanStart)
      ..registerCallback(_onPanUpdate);
  }

  void _clearGestures() {
    _gestureManager..removeCallback(_onPanStart)..removeCallback(_onPanUpdate);
  }

  void _updateVisibleCandles() {
    final candles = widget.candles;

    var start =
        candles.indexWhere((candle) => _xAxis.leftBoundEpoch < candle.epoch);
    var end = candles
        .lastIndexWhere((candle) => candle.epoch < _xAxis.rightBoundEpoch);

    if (start == -1 || end == -1) {
      visibleCandles = [];
      return;
    }

    // Include nearby points outside the viewport, so the line extends beyond the side edges.
    if (start > 0) start -= 1;
    if (end < candles.length - 1) end += 1;

    visibleCandles = candles.sublist(start, end + 1);
  }

  void _updateQuoteBoundTargets() {
    if (visibleCandles.isEmpty) return;

    final minQuote = visibleCandles.map((candle) => candle.low).reduce(min);
    final maxQuote = visibleCandles.map((candle) => candle.high).reduce(max);

    if (minQuote != bottomBoundQuoteTarget) {
      bottomBoundQuoteTarget = minQuote;
      _bottomBoundQuoteAnimationController.animateTo(
        bottomBoundQuoteTarget,
        curve: Curves.easeOut,
      );
    }
    if (maxQuote != topBoundQuoteTarget) {
      topBoundQuoteTarget = maxQuote;
      _topBoundQuoteAnimationController.animateTo(
        topBoundQuoteTarget,
        curve: Curves.easeOut,
      );
    }
  }

  Tick _candleToTick(Candle candle) {
    return Tick(
      epoch: candle.epoch,
      quote: candle.close,
    );
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

      _updateVisibleCandles();
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
              loadingRightBoundX: visibleCandles?.isEmpty ?? false
                  ? _xAxis.width
                  : _xAxis.xFromEpoch(visibleCandles.first.epoch),
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: ChartPainter(
              candles: _getChartCandles(),
              style: _chartPaintingStyle,
              granularity: context.watch<XAxisModel>().granularity,
              pipSize: widget.pipSize,
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: CurrentTickPainter(
              animatedCurrentTick: _getAnimatedCurrentTick(),
              blinkAnimationProgress: _currentTickBlinkAnimation.value,
              pipSize: widget.pipSize,
              quoteLabelsAreaWidth: quoteLabelsAreaWidth,
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
              style: context.watch<ChartTheme>().currentTickStyle,
            ),
          ),
          CrosshairArea(
            visibleCandles: visibleCandles,
            style: _chartPaintingStyle,
            pipSize: widget.pipSize,
            quoteToCanvasY: _quoteToCanvasY,
            // TODO(Rustem): remove callbacks when axis models are provided
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
          if (_isScrollToNowAvailable)
            Positioned(
              bottom: 30 + timeLabelsAreaHeight,
              right: 30 + quoteLabelsAreaWidth,
              child: _buildScrollToNowButton(),
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

  List<Candle> _getChartCandles() {
    if (visibleCandles.isEmpty) return [];

    final currentTickVisible = visibleCandles.last == widget.candles.last;
    final animatedCurrentTick = _getAnimatedCurrentTick();

    if (currentTickVisible && animatedCurrentTick != null) {
      final excludeLast =
          visibleCandles.take(visibleCandles.length - 1).toList();
      final animatedLast = visibleCandles.last.copyWith(
        epoch: animatedCurrentTick.epoch,
        close: animatedCurrentTick.quote,
      );
      return excludeLast + [animatedLast];
    } else {
      return visibleCandles;
    }
  }

  Tick _getAnimatedCurrentTick() {
    if (widget.candles.isEmpty) return null;

    final currentTick = _candleToTick(widget.candles.last);

    if (prevTick == null) return currentTick;

    final epochDiff = currentTick.epoch - prevTick.epoch;
    final quoteDiff = currentTick.quote - prevTick.quote;

    final animatedEpochDiff = (epochDiff * _currentTickAnimation.value).toInt();
    final animatedQuoteDiff = quoteDiff * _currentTickAnimation.value;

    return Tick(
      epoch: prevTick.epoch + animatedEpochDiff,
      quote: prevTick.quote + animatedQuoteDiff,
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

  IconButton _buildScrollToNowButton() {
    return IconButton(
      icon: Icon(Icons.arrow_forward, color: Colors.white),
      onPressed: _xAxis.scrollToNow,
    );
  }

  void _loadMoreHistory() {
    final int widthInMs = _xAxis.msFromPx(_xAxis.width);

    requestedLeftEpoch = widget.candles.first.epoch - (2 * widthInMs);

    widget.onLoadHistory?.call(
      requestedLeftEpoch,
      widget.candles.first.epoch,
      (2 * widthInMs) ~/ _xAxis.granularity,
    );
  }
}
