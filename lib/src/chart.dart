import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'callbacks.dart';
import 'crosshair/crosshair_area.dart';
import 'gestures/gesture_manager.dart';
import 'logic/conversion.dart';
import 'logic/quote_grid.dart';
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
    this.theme,
    this.onCrosshairAppeared,
    this.onLoadHistory,
    Key key,
  }) : super(key: key);

  /// Chart's main data series
  final BaseSeries<Tick> mainSeries;

  /// Number of digits in price after decimal point.
  final int pipSize;

  /// Called when crosshair details appear after long press.
  final VoidCallback onCrosshairAppeared;

  /// Called when chart is scrolled back and missing data is visible.
  final OnLoadHistory onLoadHistory;

  /// Chart's theme.
  final ChartTheme theme;

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
            firstCandleEpoch: mainSeries.entries.isNotEmpty
                ? mainSeries.entries.first.epoch
                : null,
            // TODO(Rustem): App should pass granularity to chart,
            // the calculation is error-prone when gaps are present
            granularity: mainSeries.entries.length >= 2
                ? mainSeries.entries[1].epoch - mainSeries.entries[0].epoch
                : null,
            child: _ChartImplementation(
              mainSeries: mainSeries,
              pipSize: pipSize,
              onCrosshairAppeared: onCrosshairAppeared,
              onLoadHistory: onLoadHistory,
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
    this.onCrosshairAppeared,
    this.onLoadHistory,
  }) : super(key: key);

  final BaseSeries mainSeries;
  final int pipSize;
  final VoidCallback onCrosshairAppeared;
  final OnLoadHistory onLoadHistory;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends State<_ChartImplementation>
    with TickerProviderStateMixin {
  Ticker ticker;

  /// Width of the area with quote labels on the right.
  double quoteLabelsAreaWidth = 70;

  /// Height of the area with time labels on the bottom.
  final double timeLabelsAreaHeight = 20;

  int requestedLeftEpoch;
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

  bool get _isScrollToNowAvailable =>
      widget.mainSeries.entries.isNotEmpty &&
      !_xAxis.animatingPan &&
      !_isCrosshairMode;

  bool get _shouldLoadMoreHistory {
    if (widget.mainSeries.entries.isEmpty) return false;

    final waitingForHistory = requestedLeftEpoch != null &&
        requestedLeftEpoch <= _xAxis.leftBoundEpoch;

    return !waitingForHistory &&
        _xAxis.leftBoundEpoch < widget.mainSeries.entries.first.epoch;
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

  XAxisModel get _xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();

    ticker = createTicker(_onNewFrame)..start();

    _setupAnimations();
    _setupGestures();
  }

  @override
  void didUpdateWidget(_ChartImplementation oldChart) {
    super.didUpdateWidget(oldChart);

    if (widget.mainSeries.id == oldChart.mainSeries.id) {
      widget.mainSeries.didUpdateSeries(oldChart.mainSeries);
    }

    _onNewTick();

    // TODO(Rustem): recalculate only when price label length has changed
    _recalculateQuoteLabelsAreaWidth();
  }

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
    _gestureManager.registerCallback(_onPanUpdate);
  }

  void _clearGestures() {
    _gestureManager.removeCallback(_onPanUpdate);
  }

  void _updateSeries() {
    widget.mainSeries.update(_xAxis.leftBoundEpoch, _xAxis.rightBoundEpoch);
  }

  void _updateQuoteBoundTargets() {
    final minQuote = widget.mainSeries.minValue;
    final maxQuote = widget.mainSeries.maxValue;

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

      _updateSeries();
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
              loadingRightBoundX: widget.mainSeries.entries.isEmpty
                  ? _xAxis.width
                  : _xAxis.xFromEpoch(widget.mainSeries.entries.first.epoch),
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: ChartPainter(
              animationInfo: AnimationInfo(
                newTickPercent: _currentTickAnimation.value,
                blinkingPercent: _currentTickBlinkAnimation.value,
              ),
              mainSeries: widget.mainSeries,
              pipSize: widget.pipSize,
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
            ),
          ),
          CrosshairArea(
            mainSeries: widget.mainSeries,
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

  void _onPanUpdate(DragUpdateDetails details) {
    final bool onQuoteLabelsArea =
        details.localPosition.dx > _xAxis.width - quoteLabelsAreaWidth;

    if (onQuoteLabelsArea) {
      _scaleVertically(details.delta.dy);
    }
  }

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

    requestedLeftEpoch =
        widget.mainSeries.entries.first.epoch - (2 * widthInMs);

    widget.onLoadHistory?.call(
      requestedLeftEpoch,
      widget.mainSeries.entries.first.epoch,
      (2 * widthInMs) ~/ _xAxis.granularity,
    );
  }
}
