import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'callbacks.dart';
import 'crosshair/crosshair_area.dart';
import 'gestures/gesture_manager.dart';
import 'logic/conversion.dart';
import 'logic/quote_grid.dart';
import 'logic/time_grid.dart';
import 'models/candle.dart';
import 'models/chart_style.dart';
import 'models/tick.dart';
import 'painters/chart_painter.dart';
import 'painters/current_tick_painter.dart';
import 'painters/grid_painter.dart';
import 'painters/loading_painter.dart';

import 'theme/chart_default_dark_theme.dart';
import 'theme/chart_default_light_theme.dart';
import 'theme/chart_theme.dart';
import 'theme/painting_styles/chart_paiting_style.dart';

class Chart extends StatelessWidget {
  const Chart({
    Key key,
    @required this.candles,
    @required this.pipSize,
    this.theme,
    this.onCrosshairAppeared,
    this.onLoadHistory,
    this.style = ChartStyle.candles,
  }) : super(key: key);

  final List<Candle> candles;
  final int pipSize;
  final ChartStyle style;

  /// Called when crosshair details appear after long press.
  final VoidCallback onCrosshairAppeared;

  /// Called when chart is scrolled back and missing data is visible.
  final OnLoadHistory onLoadHistory;

  /// Chart's theme
  final ChartTheme theme;

  @override
  Widget build(BuildContext context) {
    final ChartTheme chartTheme =
        theme ?? Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();

    return GestureManager(
      child: Ink(
        color: chartTheme.base08Color,
        child: _ChartImplementation(
          candles: candles,
          pipSize: pipSize,
          onCrosshairAppeared: onCrosshairAppeared,
          onLoadHistory: onLoadHistory,
          style: style,
          theme: chartTheme,
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
    this.onCrosshairAppeared,
    this.onLoadHistory,
    this.style = ChartStyle.candles,
    this.theme,
  }) : super(key: key);

  final List<Candle> candles;
  final int pipSize;
  final ChartStyle style;
  final VoidCallback onCrosshairAppeared;
  final OnLoadHistory onLoadHistory;
  final ChartTheme theme;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends State<_ChartImplementation>
    with TickerProviderStateMixin {
  Ticker ticker;

  ChartPaintingStyle _chartPaintingStyle;

  // TODO(Rustem): move to XAxisModel
  /// Max distance between [rightBoundEpoch] and [nowEpoch] in pixels. Limits panning to the right.
  final double maxCurrentTickOffset = 150;

  /// Width of the area with quote labels on the right.
  double quoteLabelsAreaWidth = 70;

  /// Height of the area with time labels on the bottom.
  final double timeLabelsAreaHeight = 20;

  List<Candle> visibleCandles = [];

  int nowEpoch;
  int requestedLeftEpoch;
  Size canvasSize;
  Tick prevTick;

  // TODO(Rustem): move to XAxisModel
  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  /// Horizontal panning is controlled by this variable.
  int rightBoundEpoch;

  // TODO(Rustem): move to XAxisModel
  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  /// Scaling is controlled by this variable.
  double msPerPx = 1000;

  // TODO(Rustem): move to XAxisModel
  /// Previous value of [msPerPx]. Used for scaling computation.
  double prevMsPerPx;

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

  // TODO(Rustem): move to XAxisModel
  AnimationController _crosshairZoomOutAnimationController;

  // TODO(Rustem): move to XAxisModel
  AnimationController _rightEpochAnimationController;
  Animation _currentTickAnimation;
  Animation _currentTickBlinkAnimation;

  // TODO(Rustem): move to XAxisModel
  Animation _crosshairZoomOutAnimation;

  // TODO(Rustem): remove crosshair related state
  bool _isCrosshairMode = false;

  // TODO(Rustem): move to XAxisModel
  bool get _isAutoPanning => rightBoundEpoch > nowEpoch && !_isCrosshairMode;

  // TODO(Rustem): move to XAxisModel
  bool get _isScrollingToNow =>
      _rightEpochAnimationController?.isAnimating ?? false;

  // TODO(Rustem): move to XAxisModel
  bool get _isScrollToNowAvailable =>
      !_isAutoPanning && !_isScrollingToNow && !_isCrosshairMode;

  bool get _shouldLoadMoreHistory {
    if (widget.candles.isEmpty) return false;

    final leftBoundEpoch = rightBoundEpoch - _pxToMs(canvasSize.width);
    final waitingForHistory =
        requestedLeftEpoch != null && requestedLeftEpoch <= leftBoundEpoch;

    return !waitingForHistory && leftBoundEpoch < widget.candles.first.epoch;
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

  @override
  void initState() {
    super.initState();

    _setChartPaintingStyle();

    nowEpoch = DateTime.now().millisecondsSinceEpoch;
    rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);

    ticker = this.createTicker(_onNewFrame);
    ticker.start();

    _setupAnimations();
    _setupGestures();
  }

  void _calculateQuoteLabelAreaWidth() {
    TextSpan textSpan = TextSpan(
      style: TextStyle(fontSize: 12),
      text: widget.candles.first.close.toStringAsFixed(widget.pipSize),
    );
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 20, maxWidth: 120);
    quoteLabelsAreaWidth = textPainter.width + 10;
  }

  @override
  void didUpdateWidget(_ChartImplementation oldChart) {
    super.didUpdateWidget(oldChart);

    if (oldChart == null || widget.style != oldChart.style) {
      _setChartPaintingStyle();
    }

    if (widget.candles.isEmpty || oldChart.candles == widget.candles) return;

    _calculateQuoteLabelAreaWidth();

    if (oldChart.candles.isNotEmpty) {
      prevTick = _candleToTick(oldChart.candles.last);
    }

    final oldGranularity = _getGranularity(oldChart.candles);
    final newGranularity = _getGranularity(widget.candles);

    if (oldGranularity != newGranularity) {
      msPerPx = _getDefaultScale(newGranularity);
      rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);
    } else {
      _onNewTick();
    }
  }

  void _setChartPaintingStyle() =>
      _chartPaintingStyle = widget.style == ChartStyle.candles
          ? widget.theme.candleStyle
          : widget.theme.lineStyle;

  @override
  void dispose() {
    _rightEpochAnimationController?.dispose();
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
    setState(() {
      final prevEpoch = nowEpoch;
      nowEpoch = DateTime.now().millisecondsSinceEpoch;
      final elapsedMs = nowEpoch - prevEpoch;

      if (_isAutoPanning) {
        rightBoundEpoch += elapsedMs;
      }

      if (_shouldLoadMoreHistory) _loadMoreHistory();
    });
  }

  void _setupAnimations() {
    _setupCurrentTickAnimation();
    _setupBlinkingAnimation();
    _setupBoundsAnimation();
    _setupCrosshairZoomOutAnimation();
    _setupRightEpochAnimation();
  }

  void _setupRightEpochAnimation() {
    _rightEpochAnimationController = AnimationController.unbounded(
      vsync: this,
      value: rightBoundEpoch.toDouble(),
    )..addListener(() {
        rightBoundEpoch = _rightEpochAnimationController.value.toInt();
        final bool hitLimit = _limitRightBoundEpoch();
        if (hitLimit) _rightEpochAnimationController.stop();
      });
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
      ..registerCallback(_onScaleAndPanStart)
      ..registerCallback(_onPanUpdate)
      ..registerCallback(_onScaleUpdate)
      ..registerCallback(_onScaleAndPanEnd);
  }

  void _clearGestures() {
    _gestureManager
      ..removeCallback(_onScaleAndPanStart)
      ..removeCallback(_onPanUpdate)
      ..removeCallback(_onScaleUpdate)
      ..removeCallback(_onScaleAndPanEnd);
  }

  void _updateVisibleCandles() {
    final candles = widget.candles;
    final leftBoundEpoch = rightBoundEpoch - _pxToMs(canvasSize.width);

    var start = candles.indexWhere((candle) => leftBoundEpoch < candle.epoch);
    var end =
        candles.lastIndexWhere((candle) => candle.epoch < rightBoundEpoch);

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

  int _pxToMs(double px) {
    return pxToMs(px, msPerPx: msPerPx);
  }

  double _msToPx(int ms) {
    return msToPx(ms, msPerPx: msPerPx);
  }

  Tick _candleToTick(Candle candle) {
    return Tick(
      epoch: candle.epoch,
      quote: candle.close,
    );
  }

  double _epochToCanvasX(int epoch) => epochToCanvasX(
        epoch: epoch,
        rightBoundEpoch: rightBoundEpoch,
        canvasWidth: canvasSize.width,
        msPerPx: msPerPx,
      );

  int _canvasXToEpoch(double x) => canvasXToEpoch(
        x: x,
        rightBoundEpoch: rightBoundEpoch,
        canvasWidth: canvasSize.width,
        msPerPx: msPerPx,
      );

  double _quoteToCanvasY(double quote) => quoteToCanvasY(
        quote: quote,
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        canvasHeight: canvasSize.height,
        topPadding: _topPadding,
        bottomPadding: _bottomPadding,
      );

  int _getGranularity(List<Candle> candles) {
    if (candles.length < 2) return -1;
    return candles[1].epoch - candles[0].epoch;
  }

  double _getDefaultScale(int granularity) {
    const int defaultIntervalWidth = 20;
    return granularity / defaultIntervalWidth;
  }

  double _getMinScale(int granularity) {
    const int maxIntervalWidth = 80;
    return granularity / maxIntervalWidth;
  }

  double _getMaxScale(int granularity) {
    const int minIntervalWidth = 4;
    return granularity / minIntervalWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
      _updateVisibleCandles();
      _updateQuoteBoundTargets();

      return Stack(
        children: <Widget>[
          CustomPaint(
            size: canvasSize,
            painter: GridPainter(
              gridTimestamps: _getGridLineTimestamps(),
              gridLineQuotes: _getGridLineQuotes(),
              pipSize: widget.pipSize,
              quoteLabelsAreaWidth: quoteLabelsAreaWidth,
              epochToCanvasX: _epochToCanvasX,
              quoteToCanvasY: _quoteToCanvasY,
              style: widget.theme.gridStyle,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: LoadingPainter(
              loadingAnimationProgress: _loadingAnimationController.value,
              loadingRightBoundX: widget.candles.isEmpty
                  ? canvasSize.width
                  : _epochToCanvasX(widget.candles.first.epoch),
              epochToCanvasX: _epochToCanvasX,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: ChartPainter(
              candles: _getChartCandles(),
              style: _chartPaintingStyle,
              pipSize: widget.pipSize,
              epochToCanvasX: _epochToCanvasX,
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
              epochToCanvasX: _epochToCanvasX,
              quoteToCanvasY: _quoteToCanvasY,
              style: widget.theme.currentTickStyle,
            ),
          ),
          CrosshairArea(
            visibleCandles: visibleCandles,
            style: _chartPaintingStyle,
            pipSize: widget.pipSize,
            epochToCanvasX: _epochToCanvasX,
            canvasXToEpoch: _canvasXToEpoch,
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

  List<DateTime> _getGridLineTimestamps() {
    return gridTimestamps(
      timeGridInterval: timeGridInterval(msPerPx),
      leftBoundEpoch:
          rightBoundEpoch - pxToMs(canvasSize.width, msPerPx: msPerPx),
      rightBoundEpoch: rightBoundEpoch,
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

  void _onScaleAndPanStart(ScaleStartDetails details) {
    _rightEpochAnimationController.stop();
    prevMsPerPx = msPerPx;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isAutoPanning) {
      _scaleWithNowFixed(details);
    } else {
      _scaleWithFocalPointFixed(details);
    }
  }

  void _scaleWithNowFixed(ScaleUpdateDetails details) {
    final nowToRightBound = _msToPx(rightBoundEpoch - nowEpoch);
    _scaleChart(details);
    setState(() {
      rightBoundEpoch = nowEpoch + _pxToMs(nowToRightBound);
    });
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final focalToRightBound = canvasSize.width - details.focalPoint.dx;
    final focalEpoch = rightBoundEpoch - _pxToMs(focalToRightBound);
    _scaleChart(details);
    setState(() {
      rightBoundEpoch = focalEpoch + _pxToMs(focalToRightBound);
    });
  }

  void _scaleChart(ScaleUpdateDetails details) {
    final granularity = _getGranularity(widget.candles);
    msPerPx = (prevMsPerPx / details.scale).clamp(
      _getMinScale(granularity),
      _getMaxScale(granularity),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      rightBoundEpoch -= _pxToMs(details.delta.dx);
      _limitRightBoundEpoch();

      if (details.localPosition.dx > canvasSize.width - quoteLabelsAreaWidth) {
        verticalPaddingFraction = ((_verticalPadding + details.delta.dy) /
                (canvasSize.height - timeLabelsAreaHeight))
            .clamp(0.05, 0.49);
      }
    });
  }

  IconButton _buildScrollToNowButton() {
    return IconButton(
      icon: Icon(Icons.arrow_forward, color: Colors.white),
      onPressed: _scrollToNow,
    );
  }

  void _scrollToNow() {
    final animationMsDuration = 600;
    final lowerBound = rightBoundEpoch.toDouble();
    final upperBound = nowEpoch +
        _pxToMs(maxCurrentTickOffset).toDouble() +
        animationMsDuration;

    if (upperBound > lowerBound) {
      _rightEpochAnimationController.value = lowerBound;
      _rightEpochAnimationController.animateTo(
        upperBound,
        curve: Curves.easeOut,
        duration: Duration(milliseconds: animationMsDuration),
      );
    }
  }

  void _onScaleAndPanEnd(ScaleEndDetails details) {
    _triggerScrollMomentum(details.velocity);
  }

  void _triggerScrollMomentum(Velocity velocity) {
    final Simulation simulation = ClampingScrollSimulation(
      position: rightBoundEpoch.toDouble(),
      velocity: -velocity.pixelsPerSecond.dx * msPerPx,
      friction: 0.015 * msPerPx,
    );
    _rightEpochAnimationController
      ..value = rightBoundEpoch.toDouble()
      ..animateWith(simulation);
  }

  /// Clamps [rightBoundEpoch] and returns true if hits the limit.
  bool _limitRightBoundEpoch() {
    if (widget.candles.isEmpty) return false;
    final int offset = _pxToMs(maxCurrentTickOffset);
    final int upperLimit = nowEpoch + offset;
    final int lowerLimit = widget.candles.first.epoch + offset;
    rightBoundEpoch = rightBoundEpoch.clamp(lowerLimit, upperLimit);
    return rightBoundEpoch == upperLimit || rightBoundEpoch == lowerLimit;
  }

  void _loadMoreHistory() {
    final int granularity = widget.candles[1].epoch - widget.candles[0].epoch;
    final int widthInMs = _pxToMs(canvasSize.width);

    requestedLeftEpoch = widget.candles.first.epoch - (2 * widthInMs);

    widget.onLoadHistory?.call(
      requestedLeftEpoch,
      widget.candles.first.epoch,
      (2 * widthInMs) ~/ granularity,
    );
  }
}
