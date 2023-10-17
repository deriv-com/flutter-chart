import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_data_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_grid_label_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_grid_line_painter.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_visualization/models/animation_info.dart';
import 'helpers/functions/conversion.dart';
import 'helpers/functions/helper_functions.dart';
import 'multiple_animated_builder.dart';
import 'y_axis/quote_grid.dart';

/// The basic chart that other charts extend from.
class BasicChart extends StatefulWidget {
  ///Initializes a basic chart.
  const BasicChart({
    required this.mainSeries,
    this.pipSize = 4,
    this.opacity = 1,
    ChartAxisConfig? chartAxisConfig,
    Key? key,
  })  : chartAxisConfig = chartAxisConfig ?? const ChartAxisConfig(),
        super(key: key);

  /// The main series to display on the chart.
  final Series mainSeries;

  /// The pip size of to paint marker labels.
  final int pipSize;

  /// The opacity of the chart's data.
  final double opacity;

  /// The axis configuration of the chart.
  final ChartAxisConfig chartAxisConfig;

  @override
  BasicChartState<BasicChart> createState() => BasicChartState<BasicChart>();
}

/// The chart state to use and build other charts from it.
class BasicChartState<T extends BasicChart> extends State<T>
    with TickerProviderStateMixin {
  /// Width of the touch area for vertical zoom (on top of quote labels).
  double quoteLabelsTouchAreaWidth = 70;

  bool _panStartedOnQuoteLabelsArea = false;

  /// The canvas size to draw the chart series and other options inside.
  Size? canvasSize;

  /// Chart widget's position on the screen.
  Offset? chartPosition;

  final GlobalKey _key = GlobalKey();

  /// The model to use to calculate grid line quotes
  YAxisModel? yAxisModel;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  double verticalPaddingFraction = 0.1;

  /// Padding should be at least half of barrier label height.
  static const double minPadding = 10;

  /// Duration of quote bounds animated transition.
  final Duration quoteBoundsAnimationDuration =
      const Duration(milliseconds: 300);

  /// Top quote bound target for animated transition.
  double topBoundQuoteTarget = 60;

  /// Bottom quote bound target for animated transition.
  double bottomBoundQuoteTarget = 30;

  /// Calculated quotes for showing the the grid line.
  List<double>? gridLineQuotes;

  late AnimationController _currentTickAnimationController;

  /// The animation controller for chart top quote bound.
  late AnimationController topBoundQuoteAnimationController;

  /// The animation controller for chart bottom quote bound.
  late AnimationController bottomBoundQuoteAnimationController;

  /// The animation of the current tick.
  late Animation<double> currentTickAnimation;

  double get _topBoundQuote => topBoundQuoteAnimationController.value;

  double get _bottomBoundQuote => bottomBoundQuoteAnimationController.value;

  /// Vertical padding in pixel.
  double get verticalPadding {
    if (canvasSize == null) {
      return 0;
    }

    final double padding = verticalPaddingFraction * canvasSize!.height;
    final double paddingValue = padding;
    if (BasicChartState.minPadding < canvasSize!.height / 2) {
      return paddingValue.clamp(
          BasicChartState.minPadding, canvasSize!.height / 2);
    } else {
      return 0;
    }
  }

  double get _topPadding => verticalPadding;

  double get _bottomPadding => verticalPadding;

  late GestureManagerState _gestureManager;

  /// The xAxis model of the chart.
  XAxisModel get xAxis => context.read<XAxisModel>();

  @override
  void initState() {
    super.initState();
    _setupInitialBounds();
    setupAnimations();
    _setupGestures();
    _updateChartPosition();
  }

  void _setupGestures() {
    _gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onPanStart)
      ..registerCallback(_onPanUpdate);
  }

  @override
  void didUpdateWidget(BasicChart oldWidget) {
    super.didUpdateWidget(oldWidget as T);

    didUpdateChartData(oldWidget);
    _updateChartPosition();
  }

  /// Whether the chart data did update or not.
  void didUpdateChartData(BasicChart oldChart) {
    if (widget.mainSeries.id == oldChart.mainSeries.id &&
        widget.mainSeries.didUpdate(oldChart.mainSeries)) {
      _playNewTickAnimation();
    }
  }

  @override
  void dispose() {
    _currentTickAnimationController.dispose();

    topBoundQuoteAnimationController.dispose();
    bottomBoundQuoteAnimationController.dispose();
    _clearGestures();
    super.dispose();
  }

  /// Call function to calculate the grid line quotes and put them inside
  /// [yAxisModel].
  List<double> calculateGridLineQuotes(YAxisModel yAxisModel) =>
      gridLineQuotes = yAxisModel.gridQuotes();

  void _playNewTickAnimation() {
    _currentTickAnimationController
      ..reset()
      ..forward();
  }

  YAxisModel _setupYAxisModel(Size canvasSize) => yAxisModel = YAxisModel(
        yTopBound: chartQuoteToCanvasY(_topBoundQuote),
        yBottomBound: chartQuoteToCanvasY(_bottomBoundQuote),
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        canvasHeight: canvasSize.height,
        topPadding: _topPadding,
        bottomPadding: _bottomPadding,
      );

  /// Called to setup the current tick bounds and crosshair zoom out animations.
  void setupAnimations() {
    _setupCurrentTickAnimation();
    _setupBoundsAnimation();
  }

  void _setupCurrentTickAnimation() {
    _currentTickAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    currentTickAnimation = CurvedAnimation(
      parent: _currentTickAnimationController,
      curve: Curves.easeOut,
    );
  }

  void _setupBoundsAnimation() {
    topBoundQuoteAnimationController = AnimationController.unbounded(
      value: topBoundQuoteTarget,
      vsync: this,
      duration: quoteBoundsAnimationDuration,
    );
    bottomBoundQuoteAnimationController = AnimationController.unbounded(
      value: bottomBoundQuoteTarget,
      vsync: this,
      duration: quoteBoundsAnimationDuration,
    );
  }

  void _clearGestures() {
    _gestureManager
      ..removeCallback(_onPanStart)
      ..removeCallback(_onPanUpdate);
  }

  /// Updates the visible data to be shown inside the chart with updating the
  /// right bound and left bound epoch.
  void updateVisibleData() =>
      widget.mainSeries.update(xAxis.leftBoundEpoch, xAxis.rightBoundEpoch);

  /// Returns the charts min/max quotes.
  List<double> getSeriesMinMaxValue() =>
      <double>[widget.mainSeries.minValue, widget.mainSeries.maxValue];

  void _updateQuoteBoundTargets() {
    final List<double> minMaxValues = getSeriesMinMaxValue();
    double minQuote = minMaxValues[0];
    double maxQuote = minMaxValues[1];

    // If the minQuote and maxQuote are the same there should be a default state
    // to show chart quotes.
    if (minQuote == maxQuote) {
      minQuote -= 2;
      maxQuote += 2;
    }

    if (!minQuote.isNaN && minQuote != bottomBoundQuoteTarget) {
      bottomBoundQuoteTarget = minQuote;
      bottomBoundQuoteAnimationController.animateTo(
        bottomBoundQuoteTarget,
        curve: Curves.easeOut,
      );
    }
    if (!maxQuote.isNaN && maxQuote != topBoundQuoteTarget) {
      topBoundQuoteTarget = maxQuote;
      topBoundQuoteAnimationController.animateTo(
        topBoundQuoteTarget,
        curve: Curves.easeOut,
      );
    }
  }

  /// Converts the chart quote to y axis value inside the canvas.
  double chartQuoteToCanvasY(double quote) => quoteToCanvasY(
        quote: quote,
        topBoundQuote: _topBoundQuote,
        bottomBoundQuote: _bottomBoundQuote,
        canvasHeight: canvasSize?.height ?? 200,
        topPadding: _topPadding,
        bottomPadding: _bottomPadding,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        key: _key,
        builder: (BuildContext context, BoxConstraints constraints) {
          final XAxisModel xAxis = context.watch<XAxisModel>();

          canvasSize = Size(
            xAxis.width!,
            constraints.maxHeight,
          );

          final YAxisModel yAxisModel = _setupYAxisModel(canvasSize!);

          updateVisibleData();
          _updateQuoteBoundTargets();
          final List<double> gridLineQuotes =
              calculateGridLineQuotes(yAxisModel);
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
        animations: getQuoteGridAnimations(),
        builder: (BuildContext context, _) => CustomPaint(
          painter: YGridLinePainter(
            gridLineQuotes: gridLineQuotes,
            quoteToCanvasY: chartQuoteToCanvasY,
            style: context.watch<ChartTheme>().gridStyle,
            labelWidth: (gridLineQuotes.isNotEmpty)
                ? labelWidth(
                    gridLineQuotes.first,
                    context.watch<ChartTheme>().gridStyle.yLabelStyle,
                    widget.pipSize,
                  )
                : 0,
          ),
        ),
      );

  /// Returns a list of animation controllers to animate the top quote grid.
  List<Listenable> getQuoteGridAnimations() => <Listenable>[
        // One bound animation is enough since they animate at the same time.
        topBoundQuoteAnimationController,
      ];

  /// Returns a list of animation controllers for animating the quote label.
  List<Listenable> getQuoteLabelAnimations() => <Listenable>[
        topBoundQuoteAnimationController,
        bottomBoundQuoteAnimationController,
      ];

  /// Returns a list of animation controllers to animate the chart data inside
  /// the chart.
  List<Listenable> getChartDataAnimations() => <Listenable>[
        topBoundQuoteAnimationController,
        bottomBoundQuoteAnimationController,
        currentTickAnimation,
      ];

  Widget _buildQuoteGridLabel(List<double> gridLineQuotes) =>
      MultipleAnimatedBuilder(
        animations: getQuoteLabelAnimations(),
        builder: (BuildContext context, _) => CustomPaint(
          size: canvasSize!,
          painter: YGridLabelPainter(
            gridLineQuotes: gridLineQuotes,
            pipSize: widget.pipSize,
            quoteToCanvasY: chartQuoteToCanvasY,
            style: context.watch<ChartTheme>().gridStyle,
          ),
        ),
      );

  // Main series and indicators on top of main series.
  Widget _buildChartData() => MultipleAnimatedBuilder(
        animations: getChartDataAnimations(),
        builder: (BuildContext context, _) => RepaintBoundary(
          child: Opacity(
            opacity: widget.opacity,
            child: CustomPaint(
              painter: ChartDataPainter(
                animationInfo: AnimationInfo(
                  currentTickPercent: currentTickAnimation.value,
                ),
                mainSeries: widget.mainSeries,
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
        ),
      );

  void _onPanStart(ScaleStartDetails details) {
    _panStartedOnQuoteLabelsArea = _onQuoteLabelsTouchArea(details.focalPoint);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartedOnQuoteLabelsArea &&
        _onQuoteLabelsTouchArea(details.globalPosition)) {
      _scaleVertically(details.delta.dy);
    }
  }

  void _updateChartPosition() =>
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        final RenderBox box =
            _key.currentContext!.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        chartPosition = Offset(position.dx, position.dy);
      });

  bool _onQuoteLabelsTouchArea(Offset position) =>
      chartPosition != null &&
      position.dx > (xAxis.width! - quoteLabelsTouchAreaWidth) &&
      position.dy > chartPosition!.dy &&
      position.dy < chartPosition!.dy + canvasSize!.height;

  void _scaleVertically(double dy) {
    setState(() {
      verticalPaddingFraction =
          ((verticalPadding + dy) / canvasSize!.height).clamp(0.05, 0.49);
    });
  }

  void _setupInitialBounds() {
    topBoundQuoteTarget = widget.chartAxisConfig.initialTopBoundQuote;
    bottomBoundQuoteTarget = widget.chartAxisConfig.initialBottomBoundQuote;
  }
}
