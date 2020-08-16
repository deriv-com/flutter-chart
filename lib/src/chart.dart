import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/painters/crosshair_painter.dart';
import 'package:deriv_chart/src/painters/loading_painter.dart';
import 'package:deriv_chart/src/theme/chart_default_theme.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'callbacks.dart';
import 'logic/conversion.dart';
import 'logic/quote_grid.dart';
import 'logic/time_grid.dart';

import 'models/chart_style.dart';
import 'models/tick.dart';
import 'models/candle.dart';

import 'painters/chart_painter.dart';
import 'painters/current_tick_painter.dart';
import 'painters/grid_painter.dart';

import 'theme/painting_styles/candle_style.dart';
import 'widgets/custom_gesture_detector.dart';
import 'widgets/crosshair_details.dart';

class Chart extends StatefulWidget {
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

  final Function onCrosshairAppeared;

  /// Pagination callback. will be called when scrolled to left and there is empty space before first [candles]
  final OnLoadHistory onLoadHistory;

  /// Chart's theme
  final ChartTheme theme;

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  Ticker ticker;

  ChartPaintingStyle _chartPaintingStyle;

  /// Max distance between [rightBoundEpoch] and [nowEpoch] in pixels. Limits panning to the right.
  final double maxCurrentTickOffset = 150;

  /// Width of the area with quote labels on the right.
  final double quoteLabelsAreaWidth = 70;

  /// Height of the area with time labels on the bottom.
  final double timeLabelsAreaHeight = 20;

  List<Candle> visibleCandles = [];

  int nowEpoch;
  Size canvasSize;
  Tick prevTick;
  Candle crosshairCandle;

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  /// Horizontal panning is controlled by this variable.
  int rightBoundEpoch;

  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  /// Scaling is controlled by this variable.
  double msPerPx = 1000;

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

  ChartTheme _chartTheme;

  AnimationController _currentTickAnimationController;
  AnimationController _currentTickBlinkingController;
  AnimationController _loadingAnimationController;
  AnimationController _topBoundQuoteAnimationController;
  AnimationController _bottomBoundQuoteAnimationController;
  AnimationController _crosshairZoomOutAnimationController;
  AnimationController _rightEpochAnimationController;
  Animation _currentTickAnimation;
  Animation _currentTickBlinkAnimation;
  Animation _crosshairZoomOutAnimation;

  bool get _isCrosshairMode => crosshairCandle != null;

  bool get _isAutoPanning => rightBoundEpoch > nowEpoch && !_isCrosshairMode;

  bool get _isScrollingToNow =>
      _rightEpochAnimationController?.isAnimating ?? false;

  bool get _isScrollToNowAvailable =>
      !_isAutoPanning && !_isScrollingToNow && !_isCrosshairMode;

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

  @override
  void initState() {
    super.initState();

    _chartTheme = widget.theme ?? ChartDefaultTheme();

    nowEpoch = DateTime.now().millisecondsSinceEpoch;
    rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);

    ticker = this.createTicker(_onNewFrame);
    ticker.start();

    _setupAnimations();
  }

  @override
  void didUpdateWidget(Chart oldChart) {
    super.didUpdateWidget(oldChart);

    _chartPaintingStyle = widget.style == ChartStyle.candles
        ? CandleStyle(
            positiveColor: _chartTheme.accentGreenColor,
            negativeColor: _chartTheme.accentRedColor,
            lineColor: _chartTheme.base04Color,
          )
        : LineStyle(
            color: _chartTheme.brandGreenishColor,
            areaColor: _chartTheme.brandGreenishColor,
          );

    if (widget.candles.isEmpty || oldChart.candles == widget.candles) return;

    if (oldChart.candles.isNotEmpty)
      prevTick = _candleToTick(oldChart.candles.last);

    final oldGranularity = _getGranularity(oldChart.candles);
    final newGranularity = _getGranularity(widget.candles);

    if (oldGranularity != newGranularity) {
      msPerPx = _getDefaultScale(newGranularity);
      rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);
    } else {
      _onNewTick();
    }
  }

  @override
  void dispose() {
    _rightEpochAnimationController?.dispose();
    _currentTickAnimationController?.dispose();
    _currentTickBlinkingController?.dispose();
    _loadingAnimationController?.dispose();
    _topBoundQuoteAnimationController?.dispose();
    _bottomBoundQuoteAnimationController?.dispose();
    _crosshairZoomOutAnimationController?.dispose();
    super.dispose();
  }

  void _onNewTick() {
    if (crosshairCandle != null &&
        crosshairCandle.epoch == widget.candles.last.epoch) {
      crosshairCandle = widget.candles.last;
    }
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
      if (canvasSize != null) {
        _updateVisibleCandles();
        _recalculateQuoteBoundTargets();
      }
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

  void _recalculateQuoteBoundTargets() {
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
    final defaultIntervalWidth = 20;
    return granularity / defaultIntervalWidth;
  }

  double _getMinScale(int granularity) {
    final maxIntervalWidth = 80;
    return granularity / maxIntervalWidth;
  }

  double _getMaxScale(int granularity) {
    final minIntervalWidth = 4;
    return granularity / minIntervalWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomGestureDetector(
          onScaleAndPanStart: _handleScaleStart,
          onPanUpdate: _handlePanUpdate,
          onScaleUpdate: _handleScaleUpdate,
          onScaleAndPanEnd: _onScaleAndPanEnd,
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressUpdate,
          onLongPressEnd: _handleLongPressEnd,
          child: LayoutBuilder(builder: (context, constraints) {
            canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

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
                    style: GridStyle(
                      _chartTheme.base07Color,
                      _chartTheme.textStyle(
                        textStyle: TextStyle(fontSize: 10),
                        color: _chartTheme.base03Color,
                      ),
                    ),
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
                    style: CurrentTickStyle(
                      color: _chartTheme.brandCoralColor,
                      labelStyle: _chartTheme.textStyle(
                        textStyle: TextStyle(
                          color: _chartTheme.base01Color,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  size: canvasSize,
                  painter: CrosshairPainter(
                    crosshairCandle: crosshairCandle,
                    style: _chartPaintingStyle,
                    pipSize: widget.pipSize,
                    epochToCanvasX: _epochToCanvasX,
                    quoteToCanvasY: _quoteToCanvasY,
                  ),
                ),
              ],
            );
          }),
        ),
        if (_isScrollToNowAvailable)
          Positioned(
            bottom: 30 + timeLabelsAreaHeight,
            right: 30 + quoteLabelsAreaWidth,
            child: _buildScrollToNowButton(),
          ),
        if (_isCrosshairMode)
          Positioned(
            top: 0,
            bottom: 0,
            width: canvasSize.width,
            left: _epochToCanvasX(crosshairCandle.epoch) - canvasSize.width / 2,
            child: Align(
              alignment: Alignment.center,
              child: CrosshairDetails(
                style: _chartPaintingStyle,
                crosshairCandle: crosshairCandle,
                pipSize: widget.pipSize,
              ),
            ),
          )
      ],
    );
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

  void _handleScaleStart(ScaleStartDetails details) {
    prevMsPerPx = msPerPx;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
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

  void _handlePanUpdate(DragUpdateDetails details) {
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

  void _handleLongPressStart(LongPressStartDetails details) {
    widget.onCrosshairAppeared?.call();
    _crosshairZoomOutAnimationController.forward();
    setState(() {
      crosshairCandle = _getClosestCandle(details.localPosition.dx);
    });
  }

  void _handleLongPressUpdate(LongPressMoveUpdateDetails details) {
    setState(() {
      crosshairCandle = _getClosestCandle(details.localPosition.dx);
    });
  }

  Candle _getClosestCandle(double canvasX) {
    final epoch = canvasXToEpoch(
      x: canvasX,
      rightBoundEpoch: rightBoundEpoch,
      canvasWidth: canvasSize.width,
      msPerPx: msPerPx,
    );
    return findClosestToEpoch(epoch, visibleCandles);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _crosshairZoomOutAnimationController.reverse();
    setState(() {
      crosshairCandle = null;
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
    _limitRightBoundEpoch();
    _onLoadHistory();
  }

  void _limitRightBoundEpoch() {
    if (widget.candles.isEmpty) return;
    final int upperLimit = nowEpoch + _pxToMs(maxCurrentTickOffset);
    final int lowerLimit =
        widget.candles.first.epoch - _pxToMs(canvasSize.width);
    rightBoundEpoch = upperLimit > lowerLimit
        ? rightBoundEpoch.clamp(lowerLimit, upperLimit)
        : lowerLimit;
  }

  void _onLoadHistory() {
    if (widget.candles.isEmpty) return;
    final leftBoundEpoch = rightBoundEpoch - _pxToMs(canvasSize.width);
    if (leftBoundEpoch < widget.candles.first.epoch) {
      int granularity = widget.candles[1].epoch - widget.candles[0].epoch;
      int widthInMs = _pxToMs(canvasSize.width);
      widget.onLoadHistory?.call(
        widget.candles.first.epoch - (2 * widthInMs),
        widget.candles.first.epoch,
        (2 * widthInMs) ~/ granularity,
      );
    }
  }
}
