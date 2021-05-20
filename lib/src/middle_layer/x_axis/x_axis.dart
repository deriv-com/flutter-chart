import 'package:deriv_chart/src/middle_layer/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'grid/time_label.dart';
import 'grid/x_grid_painter.dart';
import 'x_axis_model.dart';

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
    @required this.startWithDataFitMode,
    this.onVisibleAreaChanged,
    this.minEpoch,
    this.maxEpoch,
    Key key,
  })  : assert(child != null),
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// A reference to chart's main candles.
  final List<Tick> entries;

  /// Whether the chart is showing live data.
  final bool isLive;

  /// Starts in data fit mode.
  final bool startWithDataFitMode;

  /// Callback provided by library user.
  final VisibleAreaChangedCallback onVisibleAreaChanged;

  final int minEpoch;
  final int maxEpoch;

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
      granularity: context.read<ChartConfig>().granularity,
      animationController: _rightEpochAnimationController,
      isLive: widget.isLive,
      startWithDataFitMode: widget.startWithDataFitMode,
      onScale: _onVisibleAreaChanged,
      onScroll: _onVisibleAreaChanged,
      minEpoch: widget.minEpoch,
      maxEpoch: widget.maxEpoch,
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

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<XAxisModel>.value(
        value: _model,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Update x-axis width.
            context.watch<XAxisModel>().width = constraints.maxWidth;

            final List<DateTime> _noOverlapGridTimestamps =
                _model.getNoOverlapGridTimestamps();

            final GridStyle gridStyle = context.watch<ChartTheme>().gridStyle;

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                RepaintBoundary(
                  child: CustomPaint(
                    painter: XGridPainter(
                      timeLabels: _noOverlapGridTimestamps
                          .map<String>((DateTime time) => timeLabel(time))
                          .toList(),
                      xCoords: _noOverlapGridTimestamps
                          .map<double>((DateTime time) =>
                              _model.xFromEpoch(time.millisecondsSinceEpoch))
                          .toList(),
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
