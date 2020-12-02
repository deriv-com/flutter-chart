import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/x_axis/grid/time_label.dart';
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

  List<String> _timeLabels;
  List<double> _xCoords;

  GestureManagerState gestureManager;

  @override
  void initState() {
    super.initState();

    _rightEpochAnimationController = AnimationController.unbounded(vsync: this);

    _model = XAxisModel(
      entries: widget.entries,
      granularity: context.read<ChartConfig>().granularity,
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
    _updateTimestamps();
    widget.onVisibleAreaChanged?.call(
      _model.leftBoundEpoch,
      _model.rightBoundEpoch,
    );
  }

  @override
  void didUpdateWidget(XAxis oldWidget) {
    super.didUpdateWidget(oldWidget);
    _model.update(
      isLive: widget.isLive,
      granularity: context.read<ChartConfig>().granularity,
      entries: widget.entries,
    );
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

  void _updateTimestamps() {
    // Calculate time labels' timestamps for current scale.
    final List<DateTime> timestamps = gridTimestamps(
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
      if (timestamps.isNotEmpty) timestamps.last,
    ];
    for (final DateTime timestamp in timestamps.reversed.skip(1)) {
      final double distance = _model.pxBetween(
        timestamp.millisecondsSinceEpoch,
        _noOverlapGridTimestamps.first.millisecondsSinceEpoch,
      );
      if (distance >= _minDistanceBetweenTimeGridLines) {
        _noOverlapGridTimestamps.insert(0, timestamp);
      }
    }

    _timeLabels = _noOverlapGridTimestamps
        .map<String>((DateTime time) => timeLabel(time))
        .toList();

    _xCoords = _noOverlapGridTimestamps
        .map<double>(
            (DateTime time) => _model.xFromEpoch(time.millisecondsSinceEpoch))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XAxisModel>.value(
      value: _model,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Update x-axis width.
          context.watch<XAxisModel>().width = constraints.maxWidth;

          final GridStyle gridStyle = context.watch<ChartTheme>().gridStyle;

          return Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: XGridPainter(
                    timeLabels: _timeLabels,
                    xCoords: _xCoords,
                    style: gridStyle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: gridStyle.xLabelsAreaHeight),
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}
