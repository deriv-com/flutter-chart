import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Paints text on the canvas.
void paintText(
  Canvas canvas, {
  required String text,
  required Offset anchor,
  required TextStyle style,
  Alignment anchorAlignment = Alignment.center,
}) {
  final TextPainter painter = makeTextPainter(text, style);
  paintWithTextPainter(
    canvas,
    painter: painter,
    anchor: anchor,
    anchorAlignment: anchorAlignment,
  );
}

/// Constructs a text painter and performs layout.
///
/// Use this in combination with `paintWithTextPainter`,
/// if you need to know text size on the canvas.
///
/// e.g.
/// ```
/// final tp = makeTextPainter('Hello', style);
/// final w = tp.width; // text width
/// final h = tp.height; // text height
///
/// paintWithTextPainter(
///   canvas,
///   painter: tp,
///   anchor: Offset(0, 0),
///   anchorAlignment: Alignment.centerRight,
/// );
/// ```
TextPainter makeTextPainter(String text, TextStyle style) {
  final TextSpan span = TextSpan(
    text: text,
    style: style,
  );
  return TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
  )..layout();
}

/// Constructs a text painter that fits within the given bounds by
/// scaling the font size down if necessary (never scales up).
TextPainter makeFittedTextPainter(
  String text,
  TextStyle style, {
  required double maxWidth,
  required double maxHeight,
}) {
  final TextPainter painter = makeTextPainter(text, style);

  // Early return if already fits
  if (painter.width <= maxWidth && painter.height <= maxHeight) {
    return painter;
  }

  final double currentFontSize = style.fontSize ?? 12;
  final double widthScale = maxWidth / painter.width;
  final double heightScale = maxHeight / painter.height;
  final double scale = math.min(widthScale, heightScale);

  final TextStyle fittedStyle = style.copyWith(
    fontSize: currentFontSize * scale,
  );

  return makeTextPainter(text, fittedStyle);
}

/// Constructs a [TextPainter] by splitting [text] on the first occurrence of
/// [delimiter] and applying [primaryStyle] to the part before it and
/// [secondaryStyle] to the delimiter and the part after it.
///
/// Falls back to [makeTextPainter] with [primaryStyle] if [delimiter] is not
/// found or appears at the start of [text].
TextPainter makeDelimitedTextPainter(
  String text, {
  required String delimiter,
  required TextStyle primaryStyle,
  required TextStyle secondaryStyle,
}) {
  final int index = text.indexOf(delimiter);
  if (index > 0) {
    return TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index), style: primaryStyle),
          TextSpan(text: text.substring(index), style: secondaryStyle),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }
  return makeTextPainter(text, primaryStyle);
}

/// Nominal cap height of the chart's digit glyphs, as a fraction of the em.
///
/// `IBMPlexSans` measures 0.698 and `Inter` 0.727. Only the ratio between two
/// sizes' cap heights matters here, so being a hundredth out moves a glyph by a
/// fraction of a pixel.
const double _digitCapHeightRatio = 0.72;

/// Flutter's own fallback when a [TextStyle] leaves `fontSize` unset.
const double _defaultFontSize = 14;

double _capHeightOf(TextStyle style) =>
    (style.fontSize ?? _defaultFontSize) * _digitCapHeightRatio;

/// A line of digits, optionally with its final character laid out in a style of
/// its own — typically larger and heavier than the rest.
///
/// Every run is positioned by **cap height**: its cap-height centre is placed
/// on the anchor passed to [paint]. Two things fall out of that, both of which
/// [paintWithTextPainter] gets wrong for this kind of label:
///
///  * A single run reads as vertically centred on the anchor. Centring the
///    [TextPainter]'s line box instead centres the *leading*, not the ink —
///    and a `TextStyle.height` above the font's own ascent-plus-descent ratio
///    is distributed proportionally, so most of the excess lands above the
///    baseline. Digits have no descenders to balance it, so the glyphs sit low
///    in the box and the label looks top-heavy. At the current spot's 12px/1.67
///    that was a ~3.3px imbalance inside a 24px label.
///  * Two runs of different sizes read as centred on each other, rather than
///    hanging off a shared baseline the way differently sized children of one
///    [TextSpan] would.
///
/// Anchoring to the baseline — which [TextPainter] reports exactly — rather
/// than to the box means the styles' line heights do not affect placement at
/// all.
///
/// [trailingStyle] may be null, in which case the whole string is laid out in
/// [style]. Callers can therefore pass a nullable style straight through rather
/// than branching between this and [makeTextPainter].
class DigitLabelTextPainter {
  /// Lays [text] out immediately, so [width] is available as soon as this
  /// returns.
  ///
  /// [trailingGap] separates the leading run from the emphasised character. It
  /// is ignored when there is no emphasised character, and when [text] is a
  /// single character (there being no leading run to separate it from).
  factory DigitLabelTextPainter(
    String text, {
    required TextStyle style,
    TextStyle? trailingStyle,
    double trailingGap = 0,
  }) {
    // Nothing to emphasise: one run, and the trailing fields stay unset.
    if (trailingStyle == null || text.isEmpty) {
      return DigitLabelTextPainter._(
        leading: makeTextPainter(text, style),
        leadingCapHeight: _capHeightOf(style),
      );
    }

    final int splitIndex = text.length - 1;
    return DigitLabelTextPainter._(
      // An empty leading run still lays out one line in `style`, so its
      // metrics — and therefore its width and baseline — stay well defined.
      leading: makeTextPainter(text.substring(0, splitIndex), style),
      leadingCapHeight: _capHeightOf(style),
      trailing: makeTextPainter(text.substring(splitIndex), trailingStyle),
      trailingCapHeight: _capHeightOf(trailingStyle),
      gap: splitIndex == 0 ? 0 : trailingGap,
    );
  }

  DigitLabelTextPainter._({
    required TextPainter leading,
    required double leadingCapHeight,
    TextPainter? trailing,
    double trailingCapHeight = 0,
    double gap = 0,
  })  : _leading = leading,
        _leadingCapHeight = leadingCapHeight,
        _trailing = trailing,
        _trailingCapHeight = trailingCapHeight,
        _gap = gap;

  final TextPainter _leading;
  final double _leadingCapHeight;
  final TextPainter? _trailing;
  final double _trailingCapHeight;
  final double _gap;

  /// Total width of the laid-out line, including the gap before the emphasised
  /// character.
  double get width => _leading.width + _gap + (_trailing?.width ?? 0);

  /// Paints the line with every run's cap height centred on [center].
  void paint(Canvas canvas, {required Offset center}) {
    final double left = center.dx - width / 2;

    _paintRun(canvas, _leading, _leadingCapHeight, left, center.dy);

    final TextPainter? trailing = _trailing;
    if (trailing != null) {
      _paintRun(canvas, trailing, _trailingCapHeight,
          left + _leading.width + _gap, center.dy);
    }
  }

  /// Paints [painter] with its left edge at [left] and the centre of its cap
  /// height — not of its line box — at [centerY].
  static void _paintRun(
    Canvas canvas,
    TextPainter painter,
    double capHeight,
    double left,
    double centerY,
  ) {
    // Digits sit on the baseline and rise one cap height above it, so putting
    // the baseline half a cap height below `centerY` centres their ink on it.
    final double baseline = centerY + capHeight / 2;

    painter.paint(
      canvas,
      Offset(
        left,
        baseline -
            painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
      ),
    );
  }
}

/// Paints on the canvas with the given text painter.
void paintWithTextPainter(
  Canvas canvas, {
  required TextPainter painter,
  required Offset anchor,
  Alignment anchorAlignment = Alignment.center,
}) {
  painter.paint(
    canvas,
    Offset(
      anchor.dx - painter.width / 2 * (anchorAlignment.x + 1),
      anchor.dy - painter.height / 2 * (anchorAlignment.y + 1),
    ),
  );
}
