import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/x_axis/x_axis_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../callbacks.dart';
import '../gestures/gesture_manager.dart';
import '../theme/chart_theme.dart';
import 'grid/calc_time_grid.dart';
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
    this.onVisibleAreaChanged,
    Key key,
  })
      : assert(child != null),
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
      granularity: context
          .read<ChartConfig>()
          .granularity,
      animationController: _rightEpochAnimationController,
      isLive: widget.isLive,
      onScale: _onVisibleAreaChanged,
      onScroll: _onVisibleAreaChanged,
    );

    _ticker = createTicker(_model.onNewFrame)
      ..start();

    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_model.onScaleAndPanStart)..registerCallback(
          _model.onScaleUpdate)..registerCallback(
          _model.onPanUpdate)..registerCallback(_model.onScaleAndPanEnd);
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
      granularity: context
          .read<ChartConfig>()
          .granularity,
      entries: widget.entries,
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _rightEpochAnimationController?.dispose();

    gestureManager..removeCallback(_model.onScaleAndPanStart)..removeCallback(
        _model.onScaleUpdate)..removeCallback(
        _model.onPanUpdate)..removeCallback(_model.onScaleAndPanEnd);

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XAxisModel>.value(
      value: _model,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Update x-axis width.
          context
              .watch<XAxisModel>()
              .width = constraints.maxWidth;


          // Remove labels inside time gaps.
          List<DateTime> _noOverlapGridTimestamps = getNoOverlapGridTimestamps(
              _model);

          final GridStyle gridStyle = context
              .watch<ChartTheme>()
              .gridStyle;

          return CustomPaint(
            painter: XGridPainter(
              gridTimestamps: _noOverlapGridTimestamps,
              epochToCanvasX: _model.xFromEpoch,
              style: gridStyle,
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: gridStyle.xLabelsAreaHeight),
              child: ClipRect(
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
