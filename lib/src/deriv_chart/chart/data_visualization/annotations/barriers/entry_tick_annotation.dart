import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_entry_exit_marker.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/entry_exit_marker_style.dart';
import 'package:flutter/rendering.dart';

import '../chart_annotation.dart';

/// Entry tick dot annotation.
class EntryTickAnnotation extends ChartAnnotation<BarrierObject> {
  /// Initializes a new instance of the [EntryTickAnnotation].
  EntryTickAnnotation(
    this.tick, {
    required EntryExitMarkerStyle style,
    String? id,
  }) : super(id ?? 'EntryTickAnnotation $style', style: style);

  /// The tick which this tick annotation will be pointing to.
  final Tick tick;

  @override
  SeriesPainter<Series> createPainter() => _EntryTickAnnotationPainter(this);

  @override
  BarrierObject createObject() => BarrierObject(
        leftEpoch: tick.epoch,
        rightEpoch: tick.epoch,
        quote: tick.quote,
      );

  @override
  int? getMaxEpoch() => tick.epoch;

  @override
  int? getMinEpoch() => tick.epoch;
}

class _EntryTickAnnotationPainter extends SeriesPainter<EntryTickAnnotation> {
  _EntryTickAnnotationPainter(super.series);

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    final Offset center = Offset(
      epochToX(series.tick.epoch),
      quoteToY(series.tick.quote),
    );
    paintEntryExitMarker(canvas, center, series.style as EntryExitMarkerStyle);
  }

  @override
  List<CustomPainterSemantics> buildSemantics(
      {required Size size,
      required EpochToX epochToX,
      required QuoteToY quoteToY}) {
    return <CustomPainterSemantics>[];
  }
}
