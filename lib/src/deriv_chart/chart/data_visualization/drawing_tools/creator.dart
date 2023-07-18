import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Type for callback to pass a newly created line drawing to the parent.
typedef OnAddDrawing<T> = void Function(
  Map<String, List<T>>, {
  bool isDrawingFinished,
  bool isInfiniteDrawing,
});

/// Base class for creating a drawing which will be used by each drawing
/// creator.
abstract class Creator<T extends Drawing> extends StatefulWidget {
  /// Initializes.
  const Creator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created line drawing to the parent.
  final OnAddDrawing<T> onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  @override
  CreatorState<Drawing> createState();
}

///
abstract class CreatorState<T extends Drawing> extends State<Creator<T>> {
  /// Gesture manager state.
  late final GestureManagerState _gestureManager;

  /// Parts of a particular drawing, e.g. marker, line
  /// /// Keeps track of how many times user tapped on the chart.
  @protected
  List<T> drawingParts = <T>[];

  /// Tapped position.
  /// /// Keeps track of how many times user tapped on the chart.
  @protected
  Offset? position;

  /// Keeps track of how many times user tapped on the chart.
  @protected
  int tapCount = 0;

  /// Keeps the points tapped by the user to draw the continuous drawing.
  /// /// Keeps track of how many times user tapped on the chart.
  final List<EdgePoint> edgePoints = <EdgePoint>[];

  /// Unique drawing id.
  @protected
  String drawingId = '';

  /// If drawing has been finished.
  @protected
  bool isDrawingFinished = false;

  /// Get epoch from x.
  @protected
  int Function(double x)? epochFromX;

  @override
  void initState() {
    super.initState();
    _gestureManager = context.read<GestureManagerState>()
      ..registerCallback(onTap);
  }

  @override
  void dispose() {
    _gestureManager.removeCallback(onTap);
    super.dispose();
  }

  /// Catches each single click on the chart to create a drawing.
  void onTap(TapUpDetails details);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
