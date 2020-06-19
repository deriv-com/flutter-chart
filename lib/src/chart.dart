import 'dart:math';

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

  /// Current distance between [rightBoundEpoch] and [nowEpoch] in pixels.
  /// Used to preserve this distance during scaling.
  double currentTickOffset = 100;

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

  /// Difference between two consecutive quote labels.
  double quoteGridInterval = 1;

  /// Duration of quote bounds animated transition.
  final quoteBoundsAnimationDuration = const Duration(milliseconds: 300);

  /// Top quote bound target for animated transition.
  double topBoundQuoteTarget = 60;

  /// Bottom quote bound target for animated transition.
  double bottomBoundQuoteTarget = 30;

  AnimationController _currentTickAnimationController;
  AnimationController _topBoundQuoteAnimationController;
  AnimationController _bottomBoundQuoteAnimationController;
  Animation _currentTickAnimation;

  @override
  void initState() {
    super.initState();

    nowEpoch = DateTime.now().millisecondsSinceEpoch;
    rightBoundEpoch = nowEpoch + _pxToMs(currentTickOffset);

    ticker = this.createTicker(_onNewFrame);
    ticker.start();

    _setupAnimations();
  }

  @override
  void didUpdateWidget(Chart oldChart) {
    if (oldChart.candles.isNotEmpty &&
        oldChart.candles.last != widget.candles.last) {
      prevTick = _candleToTick(oldChart.candles.last);
      _onNewTick();
    }
    super.didUpdateWidget(oldChart);
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
      if (rightBoundEpoch > prevEpoch) {
        rightBoundEpoch += elapsedMs; // autopanning
      }
      if (canvasSize != null) {
        _updateVisibleTicks();
        _recalculateQuoteBoundTargets();
        _recalculateQuoteGridInterval();
      }
    });
  }

  void _setupAnimations() {
    _currentTickAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _currentTickAnimation = CurvedAnimation(
      parent: _currentTickAnimationController,
      curve: Curves.easeOut,
    );

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

  @override
  void dispose() {
    _currentTickAnimationController.dispose();
    super.dispose();
  }

  void _updateVisibleTicks() {
    final candles = widget.candles;
    final leftBoundEpoch = rightBoundEpoch - _pxToMs(canvasSize.width);

    var start = candles.indexWhere((candle) => leftBoundEpoch < candle.epoch);
    var end =
        candles.lastIndexWhere((candle) => candle.epoch < rightBoundEpoch);

    if (start == -1 || end == -1) return;

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

  // canvasHeight
  // topPadding
  // bottomPadding
  // topBoundQuoteTarget
  // bottomBoundQuoteTarget
  void _recalculateQuoteGridInterval() {
    final chartAreaHeight = canvasSize.height - _topPadding - _bottomPadding;
    final quoteRange = topBoundQuoteTarget - bottomBoundQuoteTarget;
    if (quoteRange <= 0) return;

    final k = chartAreaHeight / quoteRange;

    double _distanceBetweenLines() => k * quoteGridInterval;

    if (_distanceBetweenLines() < 100) {
      quoteGridInterval *= 2;
    } else if (_distanceBetweenLines() / 2 >= 100) {
      quoteGridInterval /= 2;
    }
  }

  int _pxToMs(double px) {
    return pxToMs(px, msPerPx: msPerPx);
  }

  double _msToPx(int ms) {
    return msToPx(ms, msPerPx: msPerPx);
  }

  List<Candle> _getChartTicks() {
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

  Tick _candleToTick(Candle candle) {
    return Tick(
      epoch: candle.epoch,
      quote: candle.close,
    );
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

  double get _verticalPadding =>
      verticalPaddingFraction * (canvasSize.height - timeLabelsAreaHeight);

  double get _topPadding => _verticalPadding;

  double get _bottomPadding => _verticalPadding + timeLabelsAreaHeight;

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
                candles: _getChartTicks(),
                animatedCurrentTick: _getAnimatedCurrentTick(),
                pipSize: widget.pipSize,
                style: widget.style,
                msPerPx: msPerPx,
                rightBoundEpoch: rightBoundEpoch,
                topBoundQuote: _topBoundQuoteAnimationController.value,
                bottomBoundQuote: _bottomBoundQuoteAnimationController.value,
                quoteGridInterval: quoteGridInterval,
                timeGridInterval: timeGridIntervalInSeconds(msPerPx) * 1000,
                topPadding: _topPadding,
                bottomPadding: _bottomPadding,
                quoteLabelsAreaWidth: quoteLabelsAreaWidth,
              ),
            );
          }),
        ),
        if (rightBoundEpoch < nowEpoch)
          Positioned(
            bottom: 30 + timeLabelsAreaHeight,
            right: 30 + quoteLabelsAreaWidth,
            child: _buildScrollToNowButton(),
          )
      ],
    );
  }

  void _handleScaleUpdate(details) {
    setState(() {
      msPerPx = (prevMsPerPx / details.scale).clamp(1000.0, 10000.0);

      if (rightBoundEpoch > nowEpoch) {
        rightBoundEpoch = nowEpoch + _pxToMs(currentTickOffset);
      }
    });
  }

  void _handlePanUpdate(details) {
    setState(() {
      rightBoundEpoch -= _pxToMs(details.delta.dx);
      final upperLimit = nowEpoch + _pxToMs(maxCurrentTickOffset);
      rightBoundEpoch = rightBoundEpoch.clamp(0, upperLimit);

      if (rightBoundEpoch > nowEpoch) {
        currentTickOffset = _msToPx(rightBoundEpoch - nowEpoch);
      }

      if (details.localPosition.dx > canvasSize.width - quoteLabelsAreaWidth) {
        verticalPaddingFraction = ((_verticalPadding + details.delta.dy) /
                (canvasSize.height - timeLabelsAreaHeight))
            .clamp(0.05, 0.49);
      }
    });
  }

  void _handleScaleStart(details) {
    prevMsPerPx = msPerPx;
  }

  IconButton _buildScrollToNowButton() {
    return IconButton(
      icon: Icon(Icons.arrow_forward, color: Colors.white),
      onPressed: _scrollToNow,
    );
  }

  void _scrollToNow() {
    rightBoundEpoch = nowEpoch + _pxToMs(maxCurrentTickOffset);
    currentTickOffset = maxCurrentTickOffset;
  }
}
