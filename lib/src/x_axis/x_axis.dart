import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../callbacks.dart';
import '../gestures/gesture_manager.dart';
import '../theme/chart_theme.dart';
import 'grid/calc_time_grid.dart';
import 'grid/x_grid_painter.dart';
import 'x_axis_model.dart';

const double _minDistanceBetweenTimeGridLines = 90;

/// X-axis widget.
///
/// Draws x-axis grid and manages [XAxisModel].
/// Exposes the model to all descendants.
class XAxis extends StatefulWidget {
  /// Creates x-axis the size of child.
  const XAxis({
    @required this.entries,
    @required this.child,
    @required this.isLive,
    this.onVisibleAreaChanged,
    Key key,
  })  : assert(child != null),
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// A reference to chart's main candles.
  final List<Tick> entries;

  /// Whether the chart is showing live data.
  final bool isLive;

  /// Callback provided by library user.
  final VisibleAreaChangedCallback onVisibleAreaChanged;

  @override
  _XAxisState createState() => _XAxisState();
}

class _XAxisState extends State<XAxis> with TickerProviderStateMixin {
  XAxisModel _model;
  Ticker _ticker;
  AnimationController _rightEpochAnimationController;

  GestureManagerState gestureManager;

  @override
  void initState() {
    super.initState();

    _rightEpochAnimationController = AnimationController.unbounded(vsync: this);

    _model = XAxisModel(
      entries: widget.entries,
      chartConfig: context.read<ChartConfig>(),
      animationController: _rightEpochAnimationController,
      isLive: widget.isLive,
      onScale: _onVisibleAreaChanged,
      onScroll: _onVisibleAreaChanged,
    );

    _ticker = createTicker(_model.onNewFrame)..start();

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
  void didUpdateWidget(XAxis oldWidget) {
    super.didUpdateWidget(oldWidget);
    _model
      ..updateChartConfig(context.read<ChartConfig>())
      ..updateEntries(widget.entries)
      ..updateIsLive(widget.isLive);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _rightEpochAnimationController?.dispose();

    gestureManager
      ..removeCallback(_model.onScaleAndPanStart)
      ..removeCallback(_model.onScaleUpdate)
      ..removeCallback(_model.onPanUpdate)
      ..removeCallback(_model.onScaleAndPanEnd);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XAxisModel>.value(
      value: _model,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Update x-axis width.
          context.watch<XAxisModel>().width = constraints.maxWidth;

          // Calculate time labels' timestamps for current scale.
          final List<DateTime> _gridTimestamps = gridTimestamps(
            timeGridInterval: timeGridInterval(
              _model.pxFromMs,
              minDistanceBetweenLines: _minDistanceBetweenTimeGridLines,
            ),
            leftBoundEpoch: _model.leftBoundEpoch,
            rightBoundEpoch: _model.rightBoundEpoch,
          );

          // Remove labels inside time gaps.
          // Except if the last label in the gap can fit, then keep it.
          final List<DateTime> _noOverlapGridTimestamps = [
            if (_gridTimestamps.isNotEmpty) _gridTimestamps.last,
          ];
          for (final DateTime timestamp in _gridTimestamps.reversed.skip(1)) {
            final double distance = _model.pxBetween(
              timestamp.millisecondsSinceEpoch,
              _noOverlapGridTimestamps.first.millisecondsSinceEpoch,
            );
            if (distance >= _minDistanceBetweenTimeGridLines) {
              _noOverlapGridTimestamps.insert(0, timestamp);
            }
          }

          return CustomPaint(
            painter: XGridPainter(
              gridTimestamps: _noOverlapGridTimestamps,
              epochToCanvasX: _model.xFromEpoch,
              style: context.watch<ChartTheme>().gridStyle,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
