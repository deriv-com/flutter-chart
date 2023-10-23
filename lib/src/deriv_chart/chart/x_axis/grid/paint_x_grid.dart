import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/check_new_day.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/check_new_month.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/time_label.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

/// Paints x-axis grid lines and labels.
void paintXGrid(
  Canvas canvas,
  Size size, {
  required List<double> xCoords,
  required ChartTheme style,
  required List<DateTime> timestamps,
  required int granularity,
}) {
  assert(timestamps.length == xCoords.length);
  final GridStyle gridStyle = style.gridStyle;

  _paintTimeGridLines(
    canvas,
    size,
    xCoords,
    style,
    gridStyle,
    timestamps,
    granularity
  );

  _paintTimeLabels(
    canvas,
    size,
    xCoords: xCoords,
    gridStyle: gridStyle,
    timestamps: timestamps,
  );
}

void _paintTimeGridLines(
  Canvas canvas,
  Size size,
  List<double> xCoords,
  ChartTheme style,
  GridStyle gridStyle,
  List<DateTime> time,
  int granularity,
) {
  for (int i = 0; i < xCoords.length; i++) {
    final Function seperatorFunc =
        granularity > 600000 ? checkNewMonth : checkNewDate;
    
    canvas.drawLine(
      Offset(xCoords[i], 0),
      Offset(xCoords[i], size.height - gridStyle.xLabelsAreaHeight),
      Paint()
        ..color = seperatorFunc(time[i])
            ? style.verticalBarrierStyle.color
            : gridStyle.gridLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = gridStyle.lineThickness,
    );
  }
}

void _paintTimeLabels(
  Canvas canvas,
  Size size, {
  required List<double> xCoords,
  required GridStyle gridStyle,
  required List<DateTime> timestamps,
}) {
  for (int index = 0; index < timestamps.length; index++) {
    paintText(
      canvas,
      text: timeLabel(timestamps[index]),
      anchor: Offset(
        xCoords[index],
        size.height - gridStyle.xLabelsAreaHeight / 2,
      ),
      style: gridStyle.xLabelStyle,
    );
  }
}
