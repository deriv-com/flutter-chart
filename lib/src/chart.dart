import 'dart:math';

import 'package:deriv_chart/src/logic/quote_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'logic/conversion.dart';
import 'logic/time_grid.dart' show timeGridIntervalInSeconds;
import 'chart_painter.dart';
import 'models/chart_style.dart';
import 'models/tick.dart';
import 'models/candle.dart';
import 'scale_and_pan_gesture_detector.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key key,
    @required this.candles,
    @required this.pipSize,
    this.style = ChartStyle.candles,
  }) : super(key: key);

  final List<Candle> candles;
  final int pipSize;
  final ChartStyle style;

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  Ticker ticker;

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

  AnimationController _currentTickAnimationController;
  AnimationController _currentTickBlinkingController;
  AnimationController _topBoundQuoteAnimationController;
  AnimationController _bottomBoundQuoteAnimationController;
  AnimationController _rightEpochAnimationController;
  Animation _rightEpochAnimation;
  Animation _currentTickAnimation;
  Animation _currentTickBlinkAnimation;

  bool get _shouldAutoPan => rightBoundEpoch > nowEpoch;

  double get _topBoundQuote => _topBoundQuoteAnimationController.value;

  double get _bottomBoundQuote => _bottomBoundQuoteAnimationController.value;

  double get _verticalPadding =>
      verticalPaddingFraction * (canvasSize.height - timeLabelsAreaHeight);

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

    nowEpoch = DateTime.now().millisecondsSinceEpoch;
    rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);

    ticker = this.createTicker(_onNewFrame);
    ticker.start();

    _setupAnimations();
  }

  @override
  void didUpdateWidget(Chart oldChart) {
    super.didUpdateWidget(oldChart);
    if (widget.candles.isEmpty || oldChart.candles == widget.candles) return;

    if (oldChart.candles.isNotEmpty)
      prevTick = _candleToTick(oldChart.candles.last);

    final oldGranularity = _getGranularity(oldChart.candles);
    final newGranularity = _getGranularity(widget.candles);

    if (oldGranularity != newGranularity) {
      msPerPx = _getDefaultScale(newGranularity);
      _scrollToNow();
    } else {
      _onNewTick();
    }
  }

  @override
  void dispose() {
    _currentTickAnimationController?.dispose();
    _currentTickBlinkingController?.dispose();
    _topBoundQuoteAnimationController?.dispose();
    _bottomBoundQuoteAnimationController?.dispose();
    _rightEpochAnimationController?.dispose();
    super.dispose();
  }

  void _onNewTick() {
    _currentTickAnimationController.reset();
    _currentTickAnimationController.forward();
  }

  void _onNewFrame(_) {
    setState(() {
      final prevEpoch = nowEpoch;
      nowEpoch = DateTime.now().millisecondsSinceEpoch;
      final elapsedMs = nowEpoch - prevEpoch;

      if (_shouldAutoPan) {
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
    _setupRightEpochAnimation();
  }

  void _setupRightEpochAnimation() {
    _rightEpochAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addListener(() {
            if (_rightEpochAnimation != null) {
              rightBoundEpoch = _rightEpochAnimation.value.toInt();
            }
          });
  }

  void _setupCurrentTickAnimation() {
    _currentTickAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _currentTickAnimation = CurvedAnimation(
      parent: _currentTickAnimationController,
      curve: Curves.easeOut,
    );
  }

  void _setupBlinkingAnimation() {
    _currentTickBlinkingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _currentTickBlinkingController.repeat(reverse: true);
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
        ScaleAndPanGestureDetector(
          onScaleAndPanStart: _handleScaleStart,
          onPanUpdate: _handlePanUpdate,
          onScaleUpdate: _handleScaleUpdate,
          child: LayoutBuilder(builder: (context, constraints) {
            canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

            return CustomPaint(
              size: Size.infinite,
              painter: ChartPainter(
                candles: _getChartCandles(),
                animatedCurrentTick: _getAnimatedCurrentTick(),
                blinkAnimationProgress: _currentTickBlinkAnimation.value,
                pipSize: widget.pipSize,
                style: widget.style,
                msPerPx: msPerPx,
                rightBoundEpoch: rightBoundEpoch,
                topBoundQuote: _topBoundQuote,
                bottomBoundQuote: _bottomBoundQuote,
                quoteGridInterval: quoteGridInterval(_quotePerPx),
                timeGridInterval: timeGridIntervalInSeconds(msPerPx) * 1000,
                topPadding: _topPadding,
                bottomPadding: _bottomPadding,
                quoteLabelsAreaWidth: quoteLabelsAreaWidth,
              ),
            );
          }),
        ),
        if (!_shouldAutoPan)
          Positioned(
            bottom: 30 + timeLabelsAreaHeight,
            right: 30 + quoteLabelsAreaWidth,
            child: _buildScrollToNowButton(),
          )
      ],
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
    if (prevTick == null) return null;

    final currentTick = _candleToTick(widget.candles.last);

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
    if (_shouldAutoPan) {
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
      final upperLimit = nowEpoch + _pxToMs(maxCurrentTickOffset);
      rightBoundEpoch = rightBoundEpoch.clamp(0, upperLimit);

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
    final lowerBound = rightBoundEpoch.toDouble();
    final upperBound = nowEpoch + _pxToMs(maxCurrentTickOffset).toDouble();

    if (upperBound > lowerBound) {
      _rightEpochAnimationController.reset();
      _rightEpochAnimation = Tween<double>(begin: lowerBound, end: upperBound)
          .animate(CurvedAnimation(
              parent: _rightEpochAnimationController, curve: Curves.easeOut));
      _rightEpochAnimationController.forward();
    } else {
      rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);
    }
  }
}
