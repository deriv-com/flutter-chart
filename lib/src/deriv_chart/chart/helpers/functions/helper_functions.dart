import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Returns a safe minimum with considering each value other than `double.nan`.
double safeMin(double a, double b) {
  final List<double> compareValues = _checkNan(a, b);

  return compareValues.reduce(min);
}

/// Returns a safe maximum with considering each value other than `double.nan`.
double safeMax(double a, double b) {
  final List<double> compareValues = _checkNan(a, b);

  return compareValues.reduce(max);
}

/// Wraps the painting logic with a clipping rect to avoid overflows.
void performClipping(Canvas canvas, Size size, VoidCallback paintingLogic) {
  final Rect clipRect = Rect.fromLTWH(0, 0, size.width - 70, size.height);
  canvas
    ..save()
    ..clipRect(clipRect);
  paintingLogic();
  canvas.restore();
}

List<double> _checkNan(double a, double b) {
  if (a.isNaN) {
    if (b.isNaN) {
      return const <double>[double.nan, double.nan];
    }

    return <double>[b, b];
  }

  if (b.isNaN) {
    return <double>[a, a];
  }

  return <double>[a, b];
}

/// Returns the given [duration] in H:MM:SS format.
String durationToString(Duration duration) {
  final String seconds = _twoDigitDuration(duration.inSeconds.remainder(60));
  final String minutes = _twoDigitDuration(duration.inMinutes.remainder(60));

  final String hours = duration.inHours.toString();

  // remove the hour part if there isn't any
  if (hours == '0') {
    return '$minutes:$seconds';
  } else {
    return '$hours:$minutes:$seconds';
  }
}

String _twoDigitDuration(int duration) => duration.toString().padLeft(2, '0');

/// A method used for getting color for the given [background] `brightness`.
/// If the [background] color is considered `bright` it will return
/// [Colors.black], otherwise it will return [Colors.white].
Color calculateTextColor(Color background) =>
    background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;

/// Returns the width of the label with the given text,
double labelWidth(double text, TextStyle style, int pipSize) => makeTextPainter(
      text.toStringAsFixed(pipSize),
      style,
    ).width;

/// Gets the min and max index from a list of [Tick].
MinMaxIndices getMinMaxIndex(List<Tick> ticks, int startIndex,
    [int? endIndex]) {
  final int end = endIndex ?? ticks.length - 1;
  int minIndex = end;
  int maxIndex = end;

  for (int i = end - 1; i >= startIndex; i--) {
    final Tick tick = ticks[i];
    if (tick.quote.isNaN) {
      continue;
    }

    if (tick.quote >= ticks[maxIndex].quote || ticks[maxIndex].quote.isNaN) {
      maxIndex = i;
    }
    if (tick.quote <= ticks[minIndex].quote || ticks[minIndex].quote.isNaN) {
      minIndex = i;
    }
  }

  return MinMaxIndices(minIndex, maxIndex);
}

/// A model class to hold min/max indices of a list
class MinMaxIndices {
  /// Initializes
  const MinMaxIndices(this.minIndex, this.maxIndex);

  /// Min index.
  final int minIndex;

  /// Max index.
  final int maxIndex;
}
