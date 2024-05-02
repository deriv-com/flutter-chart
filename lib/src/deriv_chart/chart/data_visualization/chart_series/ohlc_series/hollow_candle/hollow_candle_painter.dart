import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';
import '../../data_series.dart';
import '../ohlc_painting.dart';
import '../ohlc_painter.dart';

/// A [DataPainter] for painting Hollow CandleStick data.
class HollowCandlePainter extends OhlcPainter {
  /// Initializes
  HollowCandlePainter(DataSeries<Candle> series) : super(series);

  late Color _positiveColor;
  late Color _negativeColor;
  late Color _neutralColor;

  @override
  void onPaintCandle(
    Canvas canvas,
    Size size,
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  ) {
    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    _positiveColor = style.positiveColor;
    _negativeColor = style.negativeColor;
    _neutralColor = style.neutralColor;

    final Color _candleColor = currentPainting.yClose > prevPainting.yClose
        ? _negativeColor
        : currentPainting.yClose < prevPainting.yClose
            ? _positiveColor
            : _neutralColor;

    yAxisClipping(canvas, size, () {
      _drawWick(canvas, _candleColor, currentPainting);

      if (currentPainting.yOpen == currentPainting.yClose) {
        _drawLine(canvas, _candleColor, currentPainting);
      } else if (currentPainting.yOpen < currentPainting.yClose) {
        _drawFilledRect(canvas, _candleColor, currentPainting);
      } else {
        _drawHollowRect(canvas, _candleColor, currentPainting);
      }
    });
  }

  void _drawWick(Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas
      ..drawLine(
        Offset(currentPainting.xCenter, currentPainting.yHigh),
        Offset(currentPainting.xCenter, currentPainting.yClose),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      )
      ..drawLine(
        Offset(currentPainting.xCenter, currentPainting.yLow),
        Offset(currentPainting.xCenter, currentPainting.yOpen),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );
  }

  void _drawFilledRect(
      Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawRect(
      Rect.fromLTRB(
        currentPainting.xCenter - currentPainting.width / 2,
        currentPainting.yClose,
        currentPainting.xCenter + currentPainting.width / 2,
        currentPainting.yOpen,
      ),
      Paint()..color = color,
    );
  }

  void _drawHollowRect(
      Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawRect(
      Rect.fromLTRB(
        currentPainting.xCenter - currentPainting.width / 2,
        currentPainting.yOpen,
        currentPainting.xCenter + currentPainting.width / 2,
        currentPainting.yClose,
      ),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLine(Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawLine(
      Offset(currentPainting.xCenter - currentPainting.width / 2,
          currentPainting.yOpen),
      Offset(currentPainting.xCenter + currentPainting.width / 2,
          currentPainting.yOpen),
      Paint()
        ..color = color
        ..strokeWidth = 1.2,
    );
  }
}
