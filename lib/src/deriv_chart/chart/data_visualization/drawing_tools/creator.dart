import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Base class to create a drawing piece by piece collected on every gesture
abstract class Creator<T extends Drawing> extends StatefulWidget {
  /// Initializes.
  const Creator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created line drawing to the parent.
  final void Function(Map<String, List<T>> addedDrawing,
      {bool isDrawingFinished, bool isInfinitDrawing}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  @override
  CreatorState<Drawing> createState();
}

///
abstract class CreatorState<T extends Drawing> extends State<Creator<T>> {
  /// Gesture manager state.
  late GestureManagerState gestureManager;

  /// Parts of a particular drawing, e.g. marker, line
  List<T> drawingParts = <T>[];

  /// Tapped position.
  Offset? position;

  /// Keeps track of how many times user tapped on the chart.
  int tapCount = 0;

  /// Keeps the points tapped by the user to draw the continuous drawing.
  final List<EdgePoint> edgePoints = <EdgePoint>[];

  /// Unique drawing id.
  String drawingId = '';

  /// If drawing has been finished.
  bool isDrawingFinished = false;

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  @override
  void initState() {
    super.initState();
    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(onTap);
  }

  @override
  void dispose() {
    gestureManager.removeCallback(onTap);
    super.dispose();
  }

  /// Catches each single click on the chart to create a drawing.
  void onTap(TapUpDetails details);

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Container();
  }
}
