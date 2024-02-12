import 'dart:math' as math;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/models/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This is a function type used as a callback to pass a newly created drawing
/// of type [T] to the parent.
typedef OnAddDrawing<T> = void Function(
  String drawingId,
  List<T> drawingParts, {
  bool isDrawingFinished,
  bool isInfiniteDrawing,
  List<EdgePoint>? edgePoints,
});

/// This class is an abstract representation of a drawing creator, and it's a
/// [StatefulWidget]. It is generic, with the type parameter [T] constrained to
/// be a subclass of Drawing.
abstract class DrawingCreator<T extends Drawing> extends StatefulWidget {
  /// Initializes.
  const DrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    this.chartConfig,
    Key? key,
  }) : super(key: key);

  /// Chart config to get pipSize
  final ChartConfig? chartConfig;

  /// A required callback property of type [OnAddDrawing<T>] that is used to
  /// pass the newly created drawing to the parent.
  final OnAddDrawing<T> onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  @override
  DrawingCreatorState<Drawing> createState();
}

/// This class is an abstract representation of the state associated with the
/// DrawingCreator. It extends [State<DrawingCreator<T>>] and is generic with
/// the type parameter [T] constrained to be a subclass of Drawing.
abstract class DrawingCreatorState<T extends Drawing>
    extends State<DrawingCreator<T>> {
  /// Gesture manager state.
  late final GestureManagerState _gestureManager;

  /// Parts of a particular drawing, e.g. marker, line etc.
  @protected
  List<T> drawingParts = <T>[];

  /// Tapped position.
  @protected
  Offset? position;

  /// Keeps track of how many times user tapped on the chart.
  @protected
  int tapCount = 0;

  /// Keeps the points tapped by the user to draw the continuous drawing.
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

  /// Returns the specific drawing id base on selected drawing tool name.
  void generateDrawingId(String drawingToolName) {
    drawingId = '${drawingToolName}_${math.Random().nextInt(1000)}';
  }

  /// Catches each single click on the chart to create a drawing.
  void onTap(TapUpDetails details) {
    // TODO(bahar-deriv): We need to apply some refactors here once all the
    // drawing tools merged. Duplicated codes should be moved here.
    generateDrawingId(runtimeType.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
