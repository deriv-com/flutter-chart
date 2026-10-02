import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Outer size of the guide badge, the halo at its widest included.
const double accumulatorTapGuideSize = 32;

/// Gap between the band's top-left corner and the badge's box.
const double accumulatorTapGuideInset = 8;

/// Radius of the solid disc the hand sits on.
const double _coreRadius = 10;

/// How far a halo ring travels before it has faded out.
const double _ringMaxRadius = accumulatorTapGuideSize / 2;

/// The fraction of a cycle a ring is in flight for.
///
/// The remainder is the rest between pings. Without it the badge reads as a
/// strobe rather than a beat.
const double _ringLife = 0.8;

const double _ringMaxOpacity = 0.45;
const double _ringStartWidth = 2;
const double _ringEndWidth = 0.8;

/// How far the core swells on the beat, and over how much of it.
const double _coreSwell = 0.08;
const double _coreSwellLife = 0.35;

/// Ink bounds of [_handPath] inside the 12x12 box it is authored in.
const Rect _handInk = Rect.fromLTRB(1.95, 1.2, 10.2, 10.8);

/// How tall the hand is drawn, inside a 20px disc.
const double _handHeight = 11;

/// How far the hand leans, anticlockwise.
///
/// Negative because canvas y grows downwards, so a positive angle turns the
/// other way.
const double _handTilt = -math.pi / 6;

/// Where the badge sits.
///
/// Inset from the band's top-left corner rather than centred: the band is most
/// of the chart, so a badge in the middle of it reads as pointing at the price
/// rather than at the box. Clamped so a band shorter than the badge keeps it
/// centred instead of letting it hang past the lower barrier.
Offset accumulatorTapGuideCenter({
  required double bandLeft,
  required double bandTop,
  required double bandBottom,
}) {
  const double half = accumulatorTapGuideSize / 2;
  final double top = bandTop + accumulatorTapGuideInset + half;
  final double bottom = bandBottom - accumulatorTapGuideInset - half;

  return Offset(
    bandLeft + accumulatorTapGuideInset + half,
    top <= bottom ? top : (bandTop + bandBottom) / 2,
  );
}

/// Paints the one-time hint that the Accumulators band can be tapped.
///
/// A hand on a disc, with halo rings pinging off it. [pulse] is a 0..1 value
/// that repeats for as long as the hint is up; everything here is derived from
/// it, so the caller owns the tempo and this owns the shape.
///
/// Two rings are in flight half a cycle apart. One ring alone leaves a visible
/// dead beat between pings, which reads as a glitch rather than a rhythm.
void paintAccumulatorTapGuide(
  Canvas canvas, {
  required Offset center,
  required Color color,
  required double pulse,
}) {
  final Paint ringPaint = Paint()..style = PaintingStyle.stroke;

  for (final double offset in const <double>[0, 0.5]) {
    final double phase = (pulse + offset) % 1;
    if (phase >= _ringLife) {
      continue;
    }

    final double progress = phase / _ringLife;
    // Fast out of the disc, slowing as it goes: a ring at constant speed looks
    // like a growing circle, not like something emitted.
    final double eased = Curves.easeOutCubic.transform(progress);

    canvas.drawCircle(
      center,
      ui.lerpDouble(_coreRadius, _ringMaxRadius, eased)!,
      ringPaint
        ..strokeWidth = ui.lerpDouble(_ringStartWidth, _ringEndWidth, eased)!
        ..color = color.withOpacity(_ringMaxOpacity * (1 - progress)),
    );
  }

  // The disc swells as each ring leaves it, so the two read as one gesture
  // rather than as a badge with something happening around it. Twice per cycle,
  // because that is how often a ring launches.
  final double beat = (pulse * 2) % 1;
  final double swell =
      beat < _coreSwellLife ? math.sin(math.pi * beat / _coreSwellLife) : 0;
  final double coreRadius = _coreRadius * (1 + _coreSwell * swell);

  canvas
    ..drawCircle(center, coreRadius, Paint()..color = color)
    ..drawPath(
      _handPath.transform(_handTransform(center, coreRadius / _coreRadius)),
      Paint()..color = Colors.white,
    );
}

/// Scales the authored hand to [_handHeight] (times the disc's own swell, so it
/// breathes with it), tilts it, and centres its ink — not its box — on [center].
Float64List _handTransform(Offset center, double scale) {
  final double factor = (_handHeight / _handInk.height) * scale;

  // Read right to left: bring the ink's own centre to the origin, size it, turn
  // it, then put it where it belongs. Turning about the ink centre rather than
  // the glyph box is what keeps the hand centred on the disc at any angle, and
  // leaves it no further from the centre than it already was.
  return (Matrix4.identity()
        ..translate(center.dx, center.dy)
        ..rotateZ(_handTilt)
        ..scale(factor)
        ..translate(-_handInk.center.dx, -_handInk.center.dy))
      .storage;
}

/// The hand glyph, in the 12x12 box it was exported in.
///
/// Transcribed from the design's SVG rather than loaded as an asset or a font
/// glyph: one icon does not justify a dependency on the host app bundling a
/// font, and a path scales with the swell for free.
final Path _handPath = Path()
  ..moveTo(4.2, 1.95)
  ..cubicTo(4.2, 1.53563, 4.53563, 1.2, 4.95, 1.2)
  ..cubicTo(5.36438, 1.2, 5.7, 1.53563, 5.7, 1.95)
  ..lineTo(5.7, 4.72875)
  ..cubicTo(5.85938, 4.58625, 6.06938, 4.5, 6.3, 4.5)
  ..cubicTo(6.68625, 4.5, 7.01625, 4.74375, 7.14375, 5.085)
  ..cubicTo(7.30875, 4.91063, 7.54125, 4.8, 7.8, 4.8)
  ..cubicTo(8.27438, 4.8, 8.6625, 5.16562, 8.69812, 5.63062)
  ..cubicTo(8.8575, 5.48625, 9.06938, 5.4, 9.3, 5.4)
  ..cubicTo(9.79688, 5.4, 10.2, 5.80313, 10.2, 6.3)
  ..lineTo(10.2, 8.4)
  ..cubicTo(10.2, 9.72563, 9.12563, 10.8, 7.8, 10.8)
  ..lineTo(6.20063, 10.8)
  ..cubicTo(6.10688, 10.8, 6.015, 10.7944, 5.925, 10.7813)
  ..cubicTo(4.88813, 10.6763, 3.93375, 10.1438, 3.3, 9.3)
  ..lineTo(1.95, 7.5)
  ..cubicTo(1.70062, 7.16813, 1.76812, 6.69938, 2.1, 6.45)
  ..cubicTo(2.43188, 6.20063, 2.90062, 6.26813, 3.15, 6.6)
  ..lineTo(4.2, 8.00063)
  ..lineTo(4.2, 1.95)
  ..close()
  // The three gaps between the fingers, wound the other way so the disc shows
  // through them.
  ..moveTo(6.3, 6.9)
  ..cubicTo(6.3, 6.735, 6.165, 6.6, 6, 6.6)
  ..cubicTo(5.835, 6.6, 5.7, 6.735, 5.7, 6.9)
  ..lineTo(5.7, 8.7)
  ..cubicTo(5.7, 8.865, 5.835, 9, 6, 9)
  ..cubicTo(6.165, 9, 6.3, 8.865, 6.3, 8.7)
  ..lineTo(6.3, 6.9)
  ..close()
  ..moveTo(7.2, 6.6)
  ..cubicTo(7.035, 6.6, 6.9, 6.735, 6.9, 6.9)
  ..lineTo(6.9, 8.7)
  ..cubicTo(6.9, 8.865, 7.035, 9, 7.2, 9)
  ..cubicTo(7.365, 9, 7.5, 8.865, 7.5, 8.7)
  ..lineTo(7.5, 6.9)
  ..cubicTo(7.5, 6.735, 7.365, 6.6, 7.2, 6.6)
  ..close()
  ..moveTo(8.7, 6.9)
  ..cubicTo(8.7, 6.735, 8.565, 6.6, 8.4, 6.6)
  ..cubicTo(8.235, 6.6, 8.1, 6.735, 8.1, 6.9)
  ..lineTo(8.1, 8.7)
  ..cubicTo(8.1, 8.865, 8.235, 9, 8.4, 9)
  ..cubicTo(8.565, 9, 8.7, 8.865, 8.7, 8.7)
  ..lineTo(8.7, 6.9)
  ..close();
