import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Paints every existing drawing.
class DrawingPainter extends StatefulWidget {
  /// Initializes
  const DrawingPainter({
    required this.drawingData,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    Key? key,
  }) : super(key: key);

  /// Contains each drawing data
  final DrawingData? drawingData;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  @override
  _DrawingPainterState createState() => _DrawingPainterState();

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;
}

class _DrawingPainterState extends State<DrawingPainter> {
  Offset _draggedPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    return widget.drawingData != null
        ? GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                _draggedPosition = Offset(
                    xAxis.epochFromX(details.localPosition.dx).toDouble(),
                    widget.quoteFromCanvasY(details.localPosition.dy));
              });
            },
            child: CustomPaint(
              foregroundPainter: _DrawingPainter(
                drawingData: widget.drawingData!,
                theme: context.watch<ChartTheme>(),
                epochToX: xAxis.xFromEpoch,
                quoteToY: widget.quoteToCanvasY,
                draggedPosition: _draggedPosition,
              ),
              size: const Size(double.infinity, double.infinity),
            ),
          )
        : const SizedBox();
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.theme,
    required this.epochToX,
    required this.quoteToY,
    required this.draggedPosition,
  });

  final DrawingData drawingData;
  final ChartTheme theme;
  double Function(int x) epochToX;
  double Function(double y) quoteToY;
  Offset draggedPosition;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawing in drawingData.drawings) {
      drawing.onPaint(
        canvas,
        size,
        theme,
        epochToX,
        quoteToY,
        drawingData.config!,
        draggedPosition,
      );
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_DrawingPainter oldDelegate) => false;

  @override
  bool hitTest(Offset position) {
    for (final Drawing drawing in drawingData.drawings) {
      return drawing.hitTest(
        position,
        epochToX,
        draggedPosition,
        drawingData.config!,
      );
    }
    return true;
  }
}
