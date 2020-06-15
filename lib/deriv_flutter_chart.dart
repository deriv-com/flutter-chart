library deriv_flutter_chart;

import 'dart:convert' show json;
import 'dart:io' show WebSocket;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import './src/logic/conversion.dart';
import './src/chart_painter.dart';
import './src/models/tick.dart';
import './src/scale_and_pan_gesture_detector.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key key,
  }) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  Ticker ticker;

  final int intervalDuration = 1000;
  final double maxCurrentTickOffset = 150;

  final double quoteLabelsAreaWidth = 60;
  final double timeLabelsAreaHeight = 20;

  List<Tick> ticks = [];
  List<Tick> visibleTicks = [];

  int nowEpoch;
  int rightBoundEpoch; // for panning
  double intervalWidth = 25; // for scaling
  double _prevIntervalWidth;
  double currentTickOffset = 100;
  int panToCurrentAnimationStartEpoch;
  double verticalPaddingFraction = 0.1;
  double quoteGridInterval = 1;

  AnimationController _currentTickAnimationController;
  Animation _currentTickAnimation;

  /// Quote range animation.
  Size canvasSize; // to determine the range of visible ticks
  double topBoundQuoteTarget = 60;
  double bottomBoundQuoteTarget = 30;
  final quoteBoundsAnimationDuration = const Duration(milliseconds: 300);
  AnimationController _topBoundQuoteAnimationController;
  AnimationController _bottomBoundQuoteAnimationController;

  @override
  void initState() {
    super.initState();
    _initTickStream();

    nowEpoch = DateTime.now().millisecondsSinceEpoch;
    rightBoundEpoch = nowEpoch + _pxToMs(currentTickOffset);

    ticker = this.createTicker(_onNewFrame);
    ticker.start();

    _setupAnimations();
  }

  void _initTickStream() async {
    WebSocket ws;
    try {
      ws = await WebSocket.connect(
          'wss://ws.binaryws.com/websockets/v3?app_id=1089');

      if (ws?.readyState == WebSocket.open) {
        ws.listen(
          (response) {
            final data = Map<String, dynamic>.from(json.decode(response));
            final epoch = data['tick']['epoch'] * 1000;
            final quote = data['tick']['quote'];
            _onNewTick(epoch, quote.toDouble());
          },
          onDone: () => print('Done!'),
          onError: (e) => throw new Exception(e),
        );
        ws.add(json.encode({'ticks': 'R_50'}));
      }
    } catch (e) {
      ws?.close();
      print('Error: $e');
    }
  }

  void _onNewTick(int epoch, double quote) {
    setState(() {
      ticks.add(Tick(
        epoch: epoch,
        quote: quote,
      ));
    });

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
    final leftBoundEpoch = rightBoundEpoch - _pxToMs(canvasSize.width);

    var start = ticks.indexWhere((tick) => leftBoundEpoch < tick.epoch);
    var end = ticks.lastIndexWhere((tick) => tick.epoch < rightBoundEpoch);

    if (start == -1 || end == -1) return;

    if (start > 0) start -= 1;
    if (end < ticks.length - 1) end += 1;

    visibleTicks = ticks.sublist(start, end + 1);
  }

  void _recalculateQuoteBoundTargets() {
    if (visibleTicks.isEmpty) return;

    final visibleTickQuotes = visibleTicks.map((tick) => tick.quote);

    final minQuote = visibleTickQuotes.reduce(min);
    final maxQuote = visibleTickQuotes.reduce(max);

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
    return pxToMs(px, msPerPx: intervalDuration / intervalWidth);
  }

  double _msToPx(int ms) {
    return msToPx(ms, msPerPx: intervalDuration / intervalWidth);
  }

  Tick _getAnimatedCurrentTick() {
    if (ticks.length < 2) return null;

    final lastTick = ticks[ticks.length - 1];
    final secondLastTick = ticks[ticks.length - 2];

    final epochDiff = lastTick.epoch - secondLastTick.epoch;
    final quoteDiff = lastTick.quote - secondLastTick.quote;

    final animatedEpochDiff = (epochDiff * _currentTickAnimation.value).toInt();
    final animatedQuoteDiff = quoteDiff * _currentTickAnimation.value;

    return Tick(
      epoch: secondLastTick.epoch + animatedEpochDiff,
      quote: secondLastTick.quote + animatedQuoteDiff,
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
          onScaleAndPanStart: (details) {
            _prevIntervalWidth = intervalWidth;
          },
          onPanUpdate: (details) {
            setState(() {
              rightBoundEpoch -= _pxToMs(details.delta.dx);
              final upperLimit = nowEpoch + _pxToMs(maxCurrentTickOffset);
              rightBoundEpoch = rightBoundEpoch.clamp(0, upperLimit);

              if (rightBoundEpoch > nowEpoch) {
                currentTickOffset = _msToPx(rightBoundEpoch - nowEpoch);
              }

              if (details.localPosition.dx >
                  canvasSize.width - quoteLabelsAreaWidth) {
                verticalPaddingFraction =
                    ((_verticalPadding + details.delta.dy) /
                            (canvasSize.height - timeLabelsAreaHeight))
                        .clamp(0.05, 0.49);
              }
            });
          },
          onScaleUpdate: (details) {
            setState(() {
              intervalWidth =
                  (_prevIntervalWidth * details.scale).clamp(3.0, 30.0);

              if (rightBoundEpoch > nowEpoch) {
                rightBoundEpoch = nowEpoch + _pxToMs(currentTickOffset);
              }
            });
          },
          child: LayoutBuilder(builder: (context, constraints) {
            canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

            return CustomPaint(
              size: Size.infinite,
              painter: ChartPainter(
                ticks: visibleTicks,
                animatedCurrentTick: _getAnimatedCurrentTick(),
                endsWithCurrentTick:
                    visibleTicks.isNotEmpty && visibleTicks.last == ticks.last,
                msPerPx: intervalDuration / intervalWidth,
                rightBoundEpoch: rightBoundEpoch,
                topBoundQuote: _topBoundQuoteAnimationController.value,
                bottomBoundQuote: _bottomBoundQuoteAnimationController.value,
                quoteGridInterval: quoteGridInterval,
                timeGridInterval: intervalDuration * 30,
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
