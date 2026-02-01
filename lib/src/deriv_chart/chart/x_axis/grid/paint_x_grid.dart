import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/check_new_day.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/time_label.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Paints x-axis grid lines and labels.
void paintXGrid(
  Canvas canvas,
  Size size, {
  required List<double> xCoords,
  required ChartTheme style,
  required List<DateTime> timestamps,
  required double msPerPx,
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
    msPerPx,
  );

  if (kIsWeb) {
    _paintTimeLabelsWeb(
      canvas,
      size,
      xCoords: xCoords,
      gridStyle: gridStyle,
      timestamps: timestamps,
    );
  } else {
    _paintTimeLabels(
      canvas,
      size,
      xCoords: xCoords,
      gridStyle: gridStyle,
      timestamps: timestamps,
    );
  }
}

void _paintTimeGridLines(
  Canvas canvas,
  Size size,
  List<double> xCoords,
  ChartTheme style,
  GridStyle gridStyle,
  List<DateTime> time,
  double msPerPx,
) {
  final Paint normalGridPaint = Paint()
    ..color = gridStyle.gridLineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = gridStyle.lineThickness;

  final Paint verticalBarrierPaint = Paint()
    ..color = style.verticalBarrierStyle.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = gridStyle.lineThickness;

  for (int i = 0; i < xCoords.length; i++) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      canvas.drawLine(
        Offset(xCoords[i], 0),
        Offset(xCoords[i], size.height - gridStyle.xLabelsAreaHeight),
        // checking if msPerPx is <  300000
        (msPerPx < 300000 && checkNewDate(time[i]))
            ? verticalBarrierPaint
            : normalGridPaint,
      );
    });
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

void _paintTimeLabelsWeb(
  Canvas canvas,
  Size size, {
  required List<double> xCoords,
  required GridStyle gridStyle,
  required List<DateTime> timestamps,
}) {
  final TextStyle textStyle = TextStyle(
    fontSize: gridStyle.xLabelStyle.fontSize,
    height: gridStyle.xLabelStyle.height,
    color: gridStyle.xLabelStyle.color,
  );

  for (int index = 0; index < timestamps.length; index++) {
    paintText(
      canvas,
      text: timeLabel(timestamps[index]),
      anchor: Offset(
        xCoords[index],
        size.height - gridStyle.xLabelsAreaHeight / 2,
      ),
      style: textStyle,
    );
  }
}
