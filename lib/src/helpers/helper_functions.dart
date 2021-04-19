import 'dart:math';

import 'package:flutter/material.dart';

/// Gets enum value as string from the given enum
/// E.g. MovingAverage.simple -> simple
String getEnumValue<T>(T t) =>
    t.toString().substring(t.toString().indexOf('.') + 1);

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
  if (duration == null) {
    return '00:00';
  }

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
/// If the [background] color is considered `bright` it will return [Colors.black], otherwise it will return [Colors.white].
Color calculateTextColor(Color background) =>
    background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
