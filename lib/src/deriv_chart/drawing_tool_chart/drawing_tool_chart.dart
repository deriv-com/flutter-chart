import 'package:collection/collection.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget for encapsulating drawing tools related business logic
class DrawingToolChart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const DrawingToolChart({
    required this.chartQuoteFromCanvasY,
    required this.chartQuoteToCanvasY,
    required this.drawingTools,
    required this.series,
    Key? key,
  }) : super(key: key);

  /// Series of tick
  final DataSeries<Tick> series;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) chartQuoteFromCanvasY;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteToCanvasY;

  /// Contains drawing tools related data and methods
  final DrawingTools drawingTools;

  @override
  State<DrawingToolChart> createState() => _DrawingToolChartState();
}

class _DrawingToolChartState extends State<DrawingToolChart> {
  late Repository<DrawingToolConfig> repo;

  /// A method to get the list of drawing data from the repository
  List<DrawingData?> getDrawingData() => repo.items
      .map<DrawingData?>((DrawingToolConfig config) => config.drawingData)
      .toList();

  /// Sets drawing as selected and unselects the rest of drawings
  /// if any of the drawing is not finished , it selects the unfinished drawing
  void _setIsDrawingSelected(DrawingData drawing) {
    setState(() {
      drawing.isSelected = !drawing.isSelected;

      for (final DrawingData? data in getDrawingData()) {
        if (data!.id != drawing.id) {
          data.isSelected = false;
        }
      }
    });
  }

  /// Removes specific drawing from the list of drawings
  void removeUnfinishedDrawing() {
    final List<DrawingData?> unfinishedDrawings = getDrawingData()
        .where((DrawingData? data) => !data!.isDrawingFinished)
        .toList();
    repo.removeAt(getDrawingData().indexOf(unfinishedDrawings.first));
  }

  @override
  Widget build(BuildContext context) {
    repo = context.watch<Repository<DrawingToolConfig>>();

    final List<DrawingToolConfig> configs = repo.items.toList();

    final List<DrawingData?> drawings = configs
        .map<DrawingData?>((DrawingToolConfig config) => config.drawingData)
        .toList();

    return ClipRect(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (drawings.isNotEmpty)
              ...drawings.mapIndexed(
                (int index, DrawingData? drawingData) => DrawingPainter(
                  key: ValueKey<String>(
                    '''${drawingData?.id}_${context.watch<ChartConfig>().granularity}''',
                  ),
                  drawingData: drawingData,
                  quoteToCanvasY: widget.chartQuoteToCanvasY,
                  onMouseEnter: () => widget.drawingTools.onMouseEnter(index),
                  onMouseExit: () => widget.drawingTools.onMouseExit(index),
                  quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                  isDrawingMoving: widget.drawingTools.isDrawingMoving,
                  onMoveDrawing: widget.drawingTools.onMoveDrawing,
                  setIsDrawingSelected: _setIsDrawingSelected,
                  selectedDrawingTool: widget.drawingTools.selectedDrawingTool,
                  series: widget.series,
                ),
              ),
            if (widget.drawingTools.selectedDrawingTool != null)
              DrawingToolWidget(
                onAddDrawing: widget.drawingTools.onAddDrawing,
                selectedDrawingTool: widget.drawingTools.selectedDrawingTool!,
                quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                chartConfig: context.watch<ChartConfig>(),
                clearDrawingToolSelection:
                    widget.drawingTools.clearDrawingToolSelection,
                series: widget.series,
                removeUnfinishedDrawing: removeUnfinishedDrawing,
                shouldStopDrawing: widget.drawingTools.shouldStopDrawing,
              ),
            _buildDrawingAnnotations(configs),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingAnnotations(List<DrawingToolConfig> configs) {
    final DrawingToolConfig? selectedDrawing = configs.firstWhereOrNull(
        (element) =>
            element.drawingData?.isSelected == true &&
            element.drawingData?.isDrawingFinished == true);

    // Return an empty widget if there's no valid selected drawing
    if (selectedDrawing == null) {
      return const SizedBox.shrink();
    }

    if (selectedDrawing is LineDrawingToolConfig) {
      return CustomPaint(
        foregroundPainter: LineBarrierPainter(
          selectedDrawing,
          quoteToY: widget.chartQuoteToCanvasY,
          epochToX: context.watch<XAxisModel>().xFromEpoch,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// LineBarrierPainter is a subclass of CustomPainter responsible for
/// drawing barriers on a chart based on selected line points.
class LineBarrierPainter extends CustomPainter {
  /// Creates a LineBarrierPainter.
  LineBarrierPainter(
    this.config, {
    required this.quoteToY,
    required this.epochToX,
  });

  /// Line drawing tool configuration.
  final LineDrawingToolConfig config;

  /// Quote to Y conversion function.
  final QuoteToY quoteToY;

  /// Epoch to X conversion function.
  final EpochToX epochToX;

  /// Padding between the labels and the barriers.
  final double padding = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = config.edgePoints.first;
    final endPoint = config.edgePoints.last;

    final double startQuoteY = quoteToY(startPoint.quote);
    final double endQuoteY = quoteToY(endPoint.quote);
    final double startEpochX = epochToX(startPoint.epoch);
    final double endEpochX = epochToX(endPoint.epoch);

    final HorizontalBarrierStyle style =
        HorizontalBarrierStyle(color: config.lineStyle.color);

    final Paint paint = Paint()
      ..color = style.color
      ..strokeWidth = 1.0;

    final Paint barrierPaint = Paint()
      ..color = style.color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw quote labels and barriers on the vertical axis
    _drawQuoteLabelsAndBarriers(canvas, size, style, paint, barrierPaint,
        startQuoteY, endQuoteY, startPoint, endPoint);

    // Draw epoch labels and barriers on the horizontal axis
    _drawEpochLabelsAndBarriers(canvas, size, style, paint, barrierPaint,
        startEpochX, endEpochX, startPoint.epoch, endPoint.epoch);
  }

  void _drawQuoteLabelsAndBarriers(
    Canvas canvas,
    Size size,
    HorizontalBarrierStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startQuoteY,
    double endQuoteY,
    EdgePoint startPoint,
    EdgePoint endPoint,
  ) {
    final TextPainter startQuotePainter =
        makeTextPainter(startPoint.quote.toStringAsFixed(4), style.textStyle);
    final TextPainter endQuotePainter =
        makeTextPainter(endPoint.quote.toStringAsFixed(4), style.textStyle);

    final Rect startQuoteArea = Rect.fromCenter(
      center: Offset(
          size.width - padding - startQuotePainter.width / 2, startQuoteY),
      width: startQuotePainter.width + padding,
      height: style.labelHeight,
    );
    final Rect endQuoteArea = Rect.fromCenter(
      center:
          Offset(size.width - padding - endQuotePainter.width / 2, endQuoteY),
      width: endQuotePainter.width + padding,
      height: style.labelHeight,
    );

    // Draw horizontal barrier
    final Rect horizontalBarrierRect = Rect.fromPoints(
      Offset(size.width - startQuoteArea.width - padding / 2, startQuoteY),
      Offset(size.width - padding / 2, endQuoteY),
    );
    canvas.drawRect(horizontalBarrierRect, barrierPaint);

    // Draw labels with backgrounds
    _drawLabelWithBackground(
        canvas, startQuoteArea, labelPaint, startQuotePainter);
    _drawLabelWithBackground(canvas, endQuoteArea, labelPaint, endQuotePainter);
  }

  void _drawEpochLabelsAndBarriers(
    Canvas canvas,
    Size size,
    HorizontalBarrierStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startEpochX,
    double endEpochX,
    int startEpoch,
    int endEpoch,
  ) {
    final String startEpochLabel =
        DateTime.fromMillisecondsSinceEpoch(startEpoch).toLocal().toString();
    final String endEpochLabel =
        DateTime.fromMillisecondsSinceEpoch(endEpoch).toLocal().toString();

    final TextPainter startEpochPainter =
        makeTextPainter(startEpochLabel, style.textStyle);
    final TextPainter endEpochPainter =
        makeTextPainter(endEpochLabel, style.textStyle);

    final Rect startEpochArea = Rect.fromCenter(
      center:
          Offset(startEpochX, size.height - startEpochPainter.height - padding),
      width: startEpochPainter.width + padding,
      height: style.labelHeight,
    );

    final Rect endEpochArea = Rect.fromCenter(
      center:
          Offset(endEpochX, size.height - startEpochPainter.height - padding),
      width: startEpochPainter.width + padding,
      height: style.labelHeight,
    );

    // Draw vertical barrier
    final Rect verticalBarrierRect = Rect.fromPoints(
      Offset(startEpochX, size.height - startEpochArea.height - padding),
      Offset(endEpochX, size.height - padding - 2),
    );
    canvas.drawRect(verticalBarrierRect, barrierPaint);

    // Draw labels with backgrounds
    _drawLabelWithBackground(
        canvas, startEpochArea, labelPaint, startEpochPainter);
    _drawLabelWithBackground(canvas, endEpochArea, labelPaint, endEpochPainter);
  }

  void _drawLabelWithBackground(
      Canvas canvas, Rect labelArea, Paint paint, TextPainter painter) {
    _paintLabelBackground(canvas, labelArea, paint);

    paintWithTextPainter(
      canvas,
      painter: painter,
      anchor: labelArea.center,
    );
  }

  /// Paints a background based on the given label area.
  void _paintLabelBackground(Canvas canvas, Rect rect, Paint paint,
      {double radius = 4}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
