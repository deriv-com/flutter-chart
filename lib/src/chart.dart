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
import 'package:deriv_chart/src/multiple_animated_builder.dart';
import 'package:deriv_chart/src/painters/chart_data_painter.dart';
import 'package:deriv_chart/src/painters/y_grid_label_painter.dart';
import 'package:deriv_chart/src/painters/y_grid_line_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'callbacks.dart';
import 'crosshair/crosshair_area.dart';
import 'gestures/gesture_manager.dart';
import 'loading_animation.dart';
import 'logic/conversion.dart';
import 'logic/quote_grid.dart';
import 'markers/marker_area.dart';
import 'models/tick.dart';
import 'painters/chart_painter.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
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
    this.dataFitEnabled = false,
    this.opacity = 1.0,
    this.annotations,
    Key key,
  }) : super(key: key);

  /// Chart's main data series.
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

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

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
              entries: mainSeries.input,
              onVisibleAreaChanged: onVisibleAreaChanged,
              isLive: isLive,
              startWithDataFitMode: dataFitEnabled,
              child: _ChartImplementation(
                controller: controller,
                mainSeries: mainSeries,
                secondarySeries: secondarySeries,
                annotations: annotations,
                markerSeries: markerSeries,
                pipSize: pipSize,
                onCrosshairAppeared: onCrosshairAppeared,
                isLive: isLive,
                showLoadingAnimationForHistoricalData: !dataFitEnabled,
                showDataFitButton: dataFitEnabled,
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
  _ChartImplementation({
    Key key,
    @required this.mainSeries,
    @required this.pipSize,
    @required this.isLive,
    this.showLoadingAnimationForHistoricalData = true,
    this.showDataFitButton = false,
    this.markerSeries,
    this.opacity,
    this.controller,
    this.onCrosshairAppeared,
    this.secondarySeries,
    this.annotations,
  }) : super(key: key) {
    chartDataList = <ChartData>[
      mainSeries,
      if (secondarySeries != null) ...secondarySeries,
      if (annotations != null) ...annotations,
    ];
  }

  final DataSeries<Tick> mainSeries;
  final List<Series> secondarySeries;
  final List<ChartAnnotation<ChartObject>> annotations;
  final MarkerSeries markerSeries;
  final int pipSize;
  final VoidCallback onCrosshairAppeared;
  final ChartController controller;

  final bool isLive;
  final bool showLoadingAnimationForHistoricalData;
  final bool showDataFitButton;

  final double opacity;

  // Convenience list to access all chart data.
  List<ChartData> chartDataList;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends State<_ChartImplementation>
    with TickerProviderStateMixin {
  /// Width of the touch area for vertical zoom (on top of quote labels).
  double quoteLabelsTouchAreaWidth = 70;

  bool _panStartedOnQuoteLabelsArea = false;

  Size canvasSize;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  double verticalPaddingFraction = 0.1;

  /// Padding should be at least half of barrier label height.
  static const double _minPadding = 12;

  /// Duration of quote bounds animated transition.
  final quoteBoundsAnimationDuration = const Duration(milliseconds: 300);

  /// Top quote bound target for animated transition.
  double topBoundQuoteTarget = 60;

  /// Bottom quote bound target for animated transition.
  double bottomBoundQuoteTarget = 30;

  AnimationController _currentTickBlinkingController;

  // TODO(Rustem): move to YAxisModel
  AnimationController _crosshairZoomOutAnimationController;

  Animation _currentTickBlinkAnimation;

  // TODO(Rustem): move to YAxisModel
  Animation _crosshairZoomOutAnimation;

  // TODO(Rustem): remove crosshair related state
  bool _isCrosshairMode = false;

  bool get _isScrollToLastTickAvailable =>
      widget.mainSeries.entries.isNotEmpty &&
      _xAxis.rightBoundEpoch < widget.mainSeries.entries.last.epoch &&
      !_isCrosshairMode;

  _BaseChartState get _baseChartState => _baseChartKey.currentState;

  double get _topBoundQuote =>
      _baseChartState?._topBoundQuoteAnimationController?.value ?? 20;

  double get _bottomBoundQuote =>
      _baseChartState?._bottomBoundQuoteAnimationController?.value ?? 0;

  double get _verticalPadding {
    final double padding = verticalPaddingFraction * canvasSize.height;
    const double minCrosshairPadding = 80;
    final double paddingValue = padding +
        (minCrosshairPadding - padding).clamp(0, minCrosshairPadding) *
            _crosshairZoomOutAnimation.value;
    return paddingValue.clamp(_minPadding, canvasSize.height / 2);
  }

  double get _topPadding => _verticalPadding;

  double get _bottomPadding => _verticalPadding;

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
    if (widget.chartDataList != null) {
      for (final ChartData data in widget.chartDataList.where(
        // Exclude mainSeries, since its didUpdate is already called
        (ChartData d) => d.id != widget.mainSeries.id,
      )) {
        final ChartData oldData = oldChart.chartDataList.firstWhere(
          (ChartData d) => d.id == data.id,
          orElse: () => null,
        );

        data.didUpdate(oldData);
      }
    }
  }

  @override
  void dispose() {
    _currentTickBlinkingController?.dispose();

    _crosshairZoomOutAnimationController?.dispose();
    _clearGestures();
    super.dispose();
  }

  void _setupAnimations() {
    _setupBlinkingAnimation();
    _setupCrosshairZoomOutAnimation();
  }

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

  void _setupCrosshairZoomOutAnimation() {
    _crosshairZoomOutAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _crosshairZoomOutAnimation = CurvedAnimation(
      parent: _crosshairZoomOutAnimationController,
      curve: Curves.easeInOut,
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

  void _updateVisibleData() {
    for (final ChartData data in widget.chartDataList) {
      data.update(_xAxis.leftBoundEpoch, _xAxis.rightBoundEpoch);
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

  final GlobalKey _baseChartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final XAxisModel xAxis = context.watch<XAxisModel>();

        canvasSize = Size(
          xAxis.width,
          constraints.maxHeight,
        );

        _updateVisibleData();

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // _buildQuoteGridLine(gridLineQuotes),
            if (widget.showLoadingAnimationForHistoricalData ||
                widget.mainSeries.entries.isEmpty)
              _buildLoadingAnimation(),
            _buildChartData(),
            // _buildQuoteGridLabel(gridLineQuotes),
            _BaseChart(
              key: _baseChartKey,
              mainSeries: widget.mainSeries,
              pipSize: widget.pipSize,
            ),
            _buildAnnotations(),
            if (widget.markerSeries != null)
              MarkerArea(
                markerSeries: widget.markerSeries,
                quoteToCanvasY: _quoteToCanvasY,
              ),
            _buildCrosshairArea(),
            if (_isScrollToLastTickAvailable)
              Positioned(
                bottom: 0,
                right: quoteLabelsTouchAreaWidth,
                child: _buildScrollToLastTickButton(),
              ),
            if (widget.showDataFitButton &&
                widget.mainSeries.entries.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                child: _buildDataFitButton(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingAnimation() => LoadingAnimationArea(
        loadingRightBoundX: widget.mainSeries.visibleEntries.isEmpty
            ? _xAxis.width
            : _xAxis.xFromEpoch(
                widget.mainSeries.visibleEntries.first.epoch,
              ),
      );

  Widget _buildAnnotations() => MultipleAnimatedBuilder(
        animations: _baseChartState != null
            ? [
                _baseChartState._currentTickAnimation,
                _currentTickBlinkAnimation,
              ]
            : [_currentTickBlinkAnimation],
        builder: (BuildContext context, Widget child) =>
            Stack(fit: StackFit.expand, children: [
          if (widget.annotations != null)
            ...widget.annotations
                .map((ChartData annotation) => CustomPaint(
                      key: ValueKey<String>(annotation.id),
                      painter: ChartPainter(
                        animationInfo: AnimationInfo(
                          currentTickPercent:
                              _baseChartState._currentTickAnimation.value,
                          blinkingPercent: _currentTickBlinkAnimation.value,
                        ),
                        chartData: annotation,
                        chartConfig: context.watch<ChartConfig>(),
                        theme: context.watch<ChartTheme>(),
                        epochToCanvasX: _xAxis.xFromEpoch,
                        quoteToCanvasY: _quoteToCanvasY,
                      ),
                    ))
                .toList()
        ]),
      );

  Widget _buildCrosshairArea() => AnimatedBuilder(
        animation: _crosshairZoomOutAnimation,
        builder: (BuildContext context, Widget child) {
          return CrosshairArea(
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
          );
        },
      );

  List<double> _getGridLineQuotes() => gridQuotes(
        quoteGridInterval: quoteGridInterval(_quotePerPx),
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        canvasHeight: canvasSize.height,
        topPadding: _topPadding,
        bottomPadding: _bottomPadding,
      );

  void _onPanStart(ScaleStartDetails details) {
    _panStartedOnQuoteLabelsArea =
        _onQuoteLabelsTouchArea(details.localFocalPoint);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartedOnQuoteLabelsArea &&
        _onQuoteLabelsTouchArea(details.localPosition)) {
      _scaleVertically(details.delta.dy);
    }
  }

  bool _onQuoteLabelsTouchArea(Offset position) =>
      position.dx > _xAxis.width - quoteLabelsTouchAreaWidth;

  void _scaleVertically(double dy) {
    setState(() {
      verticalPaddingFraction =
          ((_verticalPadding + dy) / canvasSize.height).clamp(0.05, 0.49);
    });
  }

  Widget _buildScrollToLastTickButton() => Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _xAxis.scrollToLastTick,
        ),
      );

  // Main series and indicators on top of main series.
  Widget _buildChartData() => MultipleAnimatedBuilder(
        animations: _baseChartState != null
            ? <Listenable>[
                _baseChartState._topBoundQuoteAnimationController,
                _baseChartState._bottomBoundQuoteAnimationController,
                _crosshairZoomOutAnimation,
                _baseChartState._currentTickAnimation,
              ]
            : <Listenable>[
                _crosshairZoomOutAnimation,
              ],
        builder: (BuildContext context, Widget child) => RepaintBoundary(
          child: CustomPaint(
            painter: BaseChartDataPainter(
              animationInfo: AnimationInfo(
                currentTickPercent:
                    _baseChartState?._currentTickAnimation?.value ?? 0,
              ),
              series: widget.secondarySeries,
              chartConfig: context.watch<ChartConfig>(),
              theme: context.watch<ChartTheme>(),
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
              rightBoundEpoch: _xAxis.rightBoundEpoch,
              leftBoundEpoch: _xAxis.leftBoundEpoch,
              topY: _quoteToCanvasY(widget.mainSeries.maxValue),
              bottomY: _quoteToCanvasY(widget.mainSeries.minValue),
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
}

class _BaseChart extends StatefulWidget {
  const _BaseChart({
    @required this.mainSeries,
    @required this.pipSize,
    Key key,
  }) : super(key: key);

  final DataSeries<Tick> mainSeries;
  final int pipSize;

  @override
  _BaseChartState createState() => _BaseChartState();
}

class _BaseChartState extends State<_BaseChart> with TickerProviderStateMixin {
  /// Width of the touch area for vertical zoom (on top of quote labels).
  double quoteLabelsTouchAreaWidth = 70;

  bool _panStartedOnQuoteLabelsArea = false;

  Size canvasSize;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  double verticalPaddingFraction = 0.1;

  /// Padding should be at least half of barrier label height.
  static const double _minPadding = 12;

  /// Duration of quote bounds animated transition.
  final Duration quoteBoundsAnimationDuration =
      const Duration(milliseconds: 300);

  /// Top quote bound target for animated transition.
  double topBoundQuoteTarget = 60;

  /// Bottom quote bound target for animated transition.
  double bottomBoundQuoteTarget = 30;

  AnimationController _currentTickAnimationController;

  AnimationController _topBoundQuoteAnimationController;
  AnimationController _bottomBoundQuoteAnimationController;

  // TODO(Rustem): move to YAxisModel
  AnimationController _crosshairZoomOutAnimationController;

  Animation<double> _currentTickAnimation;

  // TODO(Rustem): move to YAxisModel
  Animation<double> _crosshairZoomOutAnimation;

  double get _topBoundQuote => _topBoundQuoteAnimationController.value;

  double get _bottomBoundQuote => _bottomBoundQuoteAnimationController.value;

  double get _verticalPadding {
    final double padding = verticalPaddingFraction * canvasSize.height;
    const double minCrosshairPadding = 80;
    final double paddingValue = padding +
        (minCrosshairPadding - padding).clamp(0, minCrosshairPadding) *
            _crosshairZoomOutAnimation.value;
    return paddingValue.clamp(_minPadding, canvasSize.height / 2);
  }

  double get _topPadding => _verticalPadding;

  double get _bottomPadding => _verticalPadding;

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
  }

  @override
  void didUpdateWidget(_BaseChart oldChart) {
    super.didUpdateWidget(oldChart);

    _didUpdateChartData(oldChart);
  }

  void _didUpdateChartData(_BaseChart oldChart) {
    if (widget.mainSeries.id == oldChart.mainSeries.id &&
        widget.mainSeries.didUpdate(oldChart.mainSeries)) {
      _playNewTickAnimation();
    }
  }

  @override
  void dispose() {
    _currentTickAnimationController?.dispose();

    _topBoundQuoteAnimationController?.dispose();
    _bottomBoundQuoteAnimationController?.dispose();
    _crosshairZoomOutAnimationController?.dispose();
    _clearGestures();
    super.dispose();
  }

  void _playNewTickAnimation() {
    _currentTickAnimationController
      ..reset()
      ..forward();
  }

  void _setupAnimations() {
    _setupCurrentTickAnimation();
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
      duration: const Duration(milliseconds: 150),
    );
    _crosshairZoomOutAnimation = CurvedAnimation(
      parent: _crosshairZoomOutAnimationController,
      curve: Curves.easeInOut,
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

  void _updateVisibleData() =>
      widget.mainSeries.update(_xAxis.leftBoundEpoch, _xAxis.rightBoundEpoch);

  void _updateQuoteBoundTargets() {
    double minQuote = widget.mainSeries.minValue;
    double maxQuote = widget.mainSeries.maxValue;

    // If the minQuote and maxQuote are the same there should be a default state to show chart quotes.
    if (minQuote == maxQuote) {
      minQuote -= 2;
      maxQuote += 2;
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

  // Calculate the width of Y label
  double _labelWidth(double text, TextStyle style) => makeTextPainter(
        text.toStringAsFixed(widget.pipSize),
        style,
      ).width;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final XAxisModel xAxis = context.watch<XAxisModel>();

          canvasSize = Size(
            xAxis.width,
            constraints.maxHeight,
          );

          _updateVisibleData();
          _updateQuoteBoundTargets();

          final List<double> gridLineQuotes = _getGridLineQuotes();

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildQuoteGridLine(gridLineQuotes),
              _buildChartData(),
              _buildQuoteGridLabel(gridLineQuotes),
            ],
          );
        },
      );

  Widget _buildQuoteGridLine(List<double> gridLineQuotes) =>
      MultipleAnimatedBuilder(
        animations: <Listenable>[
          // One bound animation is enough since they animate at the same time.
          _topBoundQuoteAnimationController,
          _crosshairZoomOutAnimation,
        ],
        builder: (BuildContext context, Widget child) => CustomPaint(
          painter: YGridLinePainter(
            gridLineQuotes: gridLineQuotes,
            quoteToCanvasY: _quoteToCanvasY,
            style: context.watch<ChartTheme>().gridStyle,
            labelWidth: _labelWidth(gridLineQuotes.first,
                context.watch<ChartTheme>().gridStyle.yLabelStyle),
          ),
        ),
      );

  Widget _buildQuoteGridLabel(List<double> gridLineQuotes) =>
      MultipleAnimatedBuilder(
        animations: <Listenable>[
          _topBoundQuoteAnimationController,
          _bottomBoundQuoteAnimationController,
          _crosshairZoomOutAnimation,
        ],
        builder: (BuildContext context, Widget child) => CustomPaint(
          size: canvasSize,
          painter: YGridLabelPainter(
            gridLineQuotes: gridLineQuotes,
            pipSize: widget.pipSize,
            quoteToCanvasY: _quoteToCanvasY,
            style: context.watch<ChartTheme>().gridStyle,
          ),
        ),
      );

  // Main series and indicators on top of main series.
  Widget _buildChartData() => MultipleAnimatedBuilder(
        animations: <Listenable>[
          _topBoundQuoteAnimationController,
          _bottomBoundQuoteAnimationController,
          _crosshairZoomOutAnimation,
          _currentTickAnimation,
        ],
        builder: (BuildContext context, Widget child) => RepaintBoundary(
          child: CustomPaint(
            painter: ChartDataPainter(
              animationInfo: AnimationInfo(
                currentTickPercent: _currentTickAnimation.value,
              ),
              mainSeries: widget.mainSeries,
              chartConfig: context.watch<ChartConfig>(),
              theme: context.watch<ChartTheme>(),
              epochToCanvasX: _xAxis.xFromEpoch,
              quoteToCanvasY: _quoteToCanvasY,
              rightBoundEpoch: _xAxis.rightBoundEpoch,
              leftBoundEpoch: _xAxis.leftBoundEpoch,
              topY: _quoteToCanvasY(widget.mainSeries.maxValue),
              bottomY: _quoteToCanvasY(widget.mainSeries.minValue),
            ),
          ),
        ),
      );

  List<double> _getGridLineQuotes() => gridQuotes(
        quoteGridInterval: quoteGridInterval(_quotePerPx),
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        canvasHeight: canvasSize.height,
        topPadding: _topPadding,
        bottomPadding: _bottomPadding,
      );

  void _onPanStart(ScaleStartDetails details) {
    _panStartedOnQuoteLabelsArea =
        _onQuoteLabelsTouchArea(details.localFocalPoint);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartedOnQuoteLabelsArea &&
        _onQuoteLabelsTouchArea(details.localPosition)) {
      _scaleVertically(details.delta.dy);
    }
  }

  bool _onQuoteLabelsTouchArea(Offset position) =>
      position.dx > _xAxis.width - quoteLabelsTouchAreaWidth;

  void _scaleVertically(double dy) {
    setState(() {
      verticalPaddingFraction =
          ((_verticalPadding + dy) / canvasSize.height).clamp(0.05, 0.49);
    });
  }
}
