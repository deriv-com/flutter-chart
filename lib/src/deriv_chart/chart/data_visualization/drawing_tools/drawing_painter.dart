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
    Key? key,
  }) : super(key: key);

  /// Drawing data is a Map of type:
  /// { 'id': String, 'config': DrawingToolConfig, 'drawing': Drawing }
  final DrawingData? drawingData;

  @override
  _DrawingPainterState createState() => _DrawingPainterState();
}

class _DrawingPainterState extends State<DrawingPainter> {
  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    return Stack(children: <Widget>[
      widget.drawingData != null
          ? CustomPaint(
              child: Container(),
              painter: _DrawingPainter(
                drawingData: widget.drawingData!,
                theme: context.watch<ChartTheme>(),
                epochToX: xAxis.xFromEpoch,
              ),
            )
          : Container()
    ]);
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.theme,
    required this.epochToX,
  });

  final DrawingData drawingData;
  final ChartTheme theme;
  double Function(int x) epochToX;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawing in drawingData.drawings) {
      drawing.onPaint(canvas, size, theme, epochToX, drawingData.config!);
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_DrawingPainter oldDelegate) => false;
}
