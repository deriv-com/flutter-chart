import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../models/candle_painting.dart';

/// Paints a [CandlePainting] on the given [canvas].
void paintCandle({
  @required Canvas canvas,
  @required CandlePainting cp,
  @required CandleStyle candleStyle,
  @required Paint linePaint,
  @required Paint positiveCandlePaint,
  @required Paint negativeCandlePaint,
}) {
  canvas.drawLine(
    Offset(cp.xCenter, cp.yHigh),
    Offset(cp.xCenter, cp.yLow),
    linePaint,
  );

  if (cp.yOpen == cp.yClose) {
    canvas.drawLine(
      Offset(cp.xCenter - cp.width / 2, cp.yOpen),
      Offset(cp.xCenter + cp.width / 2, cp.yOpen),
      linePaint,
    );
  } else if (cp.yOpen > cp.yClose) {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yClose,
        cp.xCenter + cp.width / 2,
        cp.yOpen,
      ),
      positiveCandlePaint,
    );
  } else {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yOpen,
        cp.xCenter + cp.width / 2,
        cp.yClose,
      ),
      negativeCandlePaint,
    );
  }
}
