import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import '../chart_annotation.dart';

/// Drag callback
typedef OnDragCallback = Function(double, bool);

/// Base class of barrier
abstract class Barrier extends ChartAnnotation<BarrierObject> {
  /// Initializes a base class of barrier.
  Barrier({
    this.epoch,
    this.value,
    String? id,
    this.title,
    this.longLine = true,
    BarrierStyle? style,
    this.label,
    this.onDrag,
  }) : super(id ?? '$title$style$longLine', style: style);

  /// Title of the barrier.
  final String? title;

  /// Barrier line start from screen edge or from the tick.
  ///
  /// Will be ignored if the barrier has only an epoch or a value, and not both.
  final bool longLine;

  /// Epoch of the vertical barrier.
  final int? epoch;

  /// The value that this barrier points to.
  final double? value;

  /// Called when the barrier is dragged.
  final OnDragCallback? onDrag;

  /// Used to store label tap area on the chart.
  late Rect labelTapArea;

  /// Label of the barrier.
  final String? label;

  @override
  int? getMaxEpoch() => epoch;

  @override
  int? getMinEpoch() => epoch;
}
