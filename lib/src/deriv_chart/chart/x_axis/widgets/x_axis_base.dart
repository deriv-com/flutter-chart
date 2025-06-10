import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../grid/x_grid_painter.dart';
import '../x_axis_model.dart';
import '../../auto_interval/zoom_level_observer.dart';

/// X-axis base widget.
///
/// Draws x-axis grid and manages [XAxisModel].
/// Exposes the model to all descendants.
class XAxisBase extends StatefulWidget {
  /// Creates x-axis the size of child.
  const XAxisBase({
    required this.entries,
    required this.child,
    required this.isLive,
    required this.startWithDataFitMode,
    required this.pipSize,
    required this.scrollAnimationDuration,
    this.onVisibleAreaChanged,
    this.minEpoch,
    this.maxEpoch,
    this.msPerPx,
    this.minIntervalWidth,
    this.maxIntervalWidth,
    this.dataFitPadding,
    Key? key,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// A reference to chart's main candles.
  final List<Tick> entries;

  /// Whether the chart is showing live data.
  final bool isLive;

  /// Starts in data fit mode.
  final bool startWithDataFitMode;

  /// Callback provided by library user.
  final VisibleAreaChangedCallback? onVisibleAreaChanged;

  /// Minimum epoch for this [XAxis].
  final int? minEpoch;

  /// Maximum epoch for this [XAxis].
  final int? maxEpoch;

  /// Number of digits after decimal point in price
  final int pipSize;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? maxIntervalWidth;

  /// Padding around data used in data-fit mode.
  final EdgeInsets? dataFitPadding;

  /// Duration of the scroll animation.
  final Duration scrollAnimationDuration;

  @override
  XAxisState createState() => XAxisState();
}

/// XAxisState
class XAxisState extends State<XAxisBase> with TickerProviderStateMixin {
  late XAxisModel _model;

  late AnimationController _rightEpochAnimationController;

  /// GestureManager
  late GestureManagerState gestureManager;

  /// XAxisModel
  XAxisModel get model => _model;

  @override
  void initState() {
    super.initState();

    final ChartConfig chartConfig = context.read<ChartConfig>();

    _rightEpochAnimationController = AnimationController.unbounded(vsync: this);
    _model = XAxisModel(
      entries: widget.entries,
      granularity: chartConfig.granularity,
      animationController: _rightEpochAnimationController,
      isLive: widget.isLive,
      startWithDataFitMode: widget.startWithDataFitMode,
      onScale: _onVisibleAreaChanged,
      onScroll: _onVisibleAreaChanged,
      minEpoch: widget.minEpoch,
      maxEpoch: widget.maxEpoch,
      maxCurrentTickOffset: chartConfig.chartAxisConfig.maxCurrentTickOffset,
      defaultIntervalWidth: chartConfig.chartAxisConfig.defaultIntervalWidth,
      msPerPx: widget.msPerPx,
      minIntervalWidth: widget.minIntervalWidth,
      maxIntervalWidth: widget.maxIntervalWidth,
      dataFitPadding: widget.dataFitPadding,
    );

    // Inject auto-interval coordinator if available
    final ZoomLevelObserver? zoomLevelObserver =
        context.read<ZoomLevelObserver?>();
    _model.setZoomLevelObserver(zoomLevelObserver);

    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_model.onScaleAndPanStart)
      ..registerCallback(_model.onScaleUpdate)
      ..registerCallback(_model.onPanUpdate)
      ..registerCallback(_model.onScaleAndPanEnd);
  }

  void _onVisibleAreaChanged() {
    widget.onVisibleAreaChanged?.call(
      _model.leftBoundEpoch,
      _model.rightBoundEpoch,
    );
  }

  @override
  void didUpdateWidget(XAxisBase oldWidget) {
    super.didUpdateWidget(oldWidget);

    _model.update(
      isLive: widget.isLive,
      granularity: context.read<ChartConfig>().granularity,
      entries: widget.entries,
      dataFitPadding: widget.dataFitPadding,
      maxCurrentTickOffset:
          context.read<ChartConfig>().chartAxisConfig.maxCurrentTickOffset,
    );
  }

  @override
  void dispose() {
    _rightEpochAnimationController.dispose();

    gestureManager
      ..removeCallback(_model.onScaleAndPanStart)
      ..removeCallback(_model.onScaleUpdate)
      ..removeCallback(_model.onPanUpdate)
      ..removeCallback(_model.onScaleAndPanEnd);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<XAxisModel>.value(
        value: _model,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final ChartTheme _chartTheme = context.watch<ChartTheme>();
            final double yAxisLabelsAreaWidth = (widget.entries.isNotEmpty
                    ? labelWidth(
                        widget.entries.first.quote,
                        _chartTheme.gridStyle.yLabelStyle,
                        widget.pipSize,
                      )
                    : 100) +
                _chartTheme.gridStyle.labelHorizontalPadding;
            // Update x-axis width.
            context.watch<XAxisModel>().width = constraints.maxWidth;
            context.watch<XAxisModel>().graphAreaWidth =
                constraints.maxWidth - yAxisLabelsAreaWidth;

            final List<DateTime> _noOverlapGridTimestamps =
                _model.getNoOverlapGridTimestamps();

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (context.read<ChartConfig>().chartAxisConfig.showEpochGrid)
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: XGridPainter(
                        timestamps: _noOverlapGridTimestamps
                            .map<DateTime>(
                                (DateTime time) => /*timeLabel(time)*/ time)
                            .toList(),
                        xCoords: _noOverlapGridTimestamps
                            .map<double>((DateTime time) =>
                                _model.xFromEpoch(time.millisecondsSinceEpoch))
                            .toList(),
                        style: _chartTheme,
                        msPerPx: _model.msPerPx,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: _chartTheme.gridStyle.xLabelsAreaHeight,
                  ),
                  child: widget.child,
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: widget.entries.isNotEmpty
                          ? yAxisLabelsAreaWidth
                          : 100,
                      height: _chartTheme.gridStyle.xLabelsAreaHeight,
                      color: _chartTheme.backgroundColor,
                    ))
              ],
            );
          },
        ),
      );
}
