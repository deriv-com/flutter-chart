import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A canvas that records only what [TextPainter.paint] needs from it: the
/// offset each glyph run is drawn at.
///
/// [TextPainter] ultimately calls `Canvas.drawParagraph`, so capturing that is
/// enough to assert where a run landed without rendering anything.
class _RecordingCanvas implements Canvas {
  final List<Offset> paragraphOffsets = <Offset>[];

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) =>
      paragraphOffsets.add(offset);

  @override
  void noSuchMethod(Invocation invocation) {}
}

void main() {
  const TextStyle style = TextStyle(
    fontSize: 12,
    height: 1.67,
    fontWeight: FontWeight.w600,
  );
  const TextStyle emphasisStyle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  group('DigitLabelTextPainter without a trailing style', () {
    test('measures the same width as a plain text painter', () {
      expect(
        DigitLabelTextPainter('1234.56', style: style).width,
        makeTextPainter('1234.56', style).width,
      );
    });

    test('ignores trailingGap, having nothing to separate', () {
      expect(
        DigitLabelTextPainter('1234.56', style: style, trailingGap: 8).width,
        makeTextPainter('1234.56', style).width,
      );
    });

    test('paints one run, horizontally centred on the anchor', () {
      final _RecordingCanvas canvas = _RecordingCanvas();
      const Offset center = Offset(100, 50);

      DigitLabelTextPainter('1234.56', style: style)
          .paint(canvas, center: center);

      final TextPainter reference = makeTextPainter('1234.56', style);
      expect(canvas.paragraphOffsets, hasLength(1));
      expect(
          canvas.paragraphOffsets.single.dx, center.dx - reference.width / 2);
    });

    test('centres the digits\' cap height on the anchor, not the line box', () {
      final _RecordingCanvas canvas = _RecordingCanvas();
      const Offset center = Offset(100, 50);

      DigitLabelTextPainter('1234.56', style: style)
          .paint(canvas, center: center);

      final TextPainter reference = makeTextPainter('1234.56', style);
      final double baseline = canvas.paragraphOffsets.single.dy +
          reference.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      // Digits occupy `baseline - capHeight .. baseline`, so this is the
      // vertical centre of the ink.
      const double capHeight = 12 * 0.72;
      expect(baseline - capHeight / 2, closeTo(center.dy, 0.01));
    });

    test('places digits identically regardless of the style\'s line height',
        () {
      // The regression this guards: `currentSpotTextStyle` carries height 1.67
      // on a 12px font, and Flutter hands most of that excess leading to the
      // ascent. Centring the line box therefore left the digits sitting ~1.6px
      // low inside the current spot's 24px label — visibly top-heavy. Cap-height
      // centring anchors to the baseline, so line height cannot shift the ink.
      Offset baselineFor(double height) {
        final _RecordingCanvas canvas = _RecordingCanvas();
        final TextStyle variant = style.copyWith(height: height);

        DigitLabelTextPainter('1234.56', style: variant)
            .paint(canvas, center: const Offset(100, 50));

        final TextPainter reference = makeTextPainter('1234.56', variant);
        return Offset(
          canvas.paragraphOffsets.single.dx,
          canvas.paragraphOffsets.single.dy +
              reference
                  .computeDistanceToActualBaseline(TextBaseline.alphabetic),
        );
      }

      final Offset tight = baselineFor(1);
      final Offset loose = baselineFor(3);

      expect(loose.dy, closeTo(tight.dy, 0.01));
      expect(loose.dx, closeTo(tight.dx, 0.01));
    });
  });

  group('DigitLabelTextPainter with a trailing style', () {
    test('adds the emphasised run and the gap to the measured width', () {
      final double width = DigitLabelTextPainter(
        '1234.56',
        style: style,
        trailingStyle: emphasisStyle,
        trailingGap: 2,
      ).width;

      expect(
        width,
        makeTextPainter('1234.5', style).width +
            2 +
            makeTextPainter('6', emphasisStyle).width,
      );
    });

    test('paints two runs, the emphasised one after the gap', () {
      final _RecordingCanvas canvas = _RecordingCanvas();
      const Offset center = Offset(100, 50);

      final DigitLabelTextPainter painter = DigitLabelTextPainter(
        '1234.56',
        style: style,
        trailingStyle: emphasisStyle,
        trailingGap: 2,
      );
      painter.paint(canvas, center: center);

      expect(canvas.paragraphOffsets, hasLength(2));

      final double left = center.dx - painter.width / 2;
      final double leadingWidth = makeTextPainter('1234.5', style).width;

      expect(canvas.paragraphOffsets.first.dx, left);
      expect(canvas.paragraphOffsets.last.dx, left + leadingWidth + 2);
    });

    test('drops the larger run below a shared baseline so the two read centred',
        () {
      final _RecordingCanvas canvas = _RecordingCanvas();
      const Offset center = Offset(100, 50);

      DigitLabelTextPainter(
        '1234.56',
        style: style,
        trailingStyle: emphasisStyle,
        trailingGap: 2,
      ).paint(canvas, center: center);

      final TextPainter leading = makeTextPainter('1234.5', style);
      final TextPainter trailing = makeTextPainter('6', emphasisStyle);

      final double leadingBaseline = canvas.paragraphOffsets.first.dy +
          leading.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final double trailingBaseline = canvas.paragraphOffsets.last.dy +
          trailing.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      // Baseline alignment would put the two on the same line; cap-height
      // centring pushes the larger run down by half the cap-height difference,
      // which is what keeps it from hanging above the smaller digits.
      expect(trailingBaseline, greaterThan(leadingBaseline));
      expect(
        trailingBaseline - leadingBaseline,
        closeTo((16 - 12) * 0.72 / 2, 0.01),
      );
    });

    test('equal styles collapse to baseline alignment', () {
      final _RecordingCanvas canvas = _RecordingCanvas();

      DigitLabelTextPainter(
        '1234.56',
        style: style,
        trailingStyle: style,
      ).paint(canvas, center: const Offset(100, 50));

      expect(
        canvas.paragraphOffsets.last.dy,
        closeTo(canvas.paragraphOffsets.first.dy, 0.01),
      );
    });

    test(
        'emphasises the whole string when it is a single character, with no gap',
        () {
      final DigitLabelTextPainter painter = DigitLabelTextPainter(
        '7',
        style: style,
        trailingStyle: emphasisStyle,
        trailingGap: 2,
      );

      expect(painter.width, makeTextPainter('7', emphasisStyle).width);
    });

    test('falls back to a single plain run for an empty string', () {
      final _RecordingCanvas canvas = _RecordingCanvas();

      DigitLabelTextPainter(
        '',
        style: style,
        trailingStyle: emphasisStyle,
      ).paint(canvas, center: const Offset(100, 50));

      expect(canvas.paragraphOffsets, hasLength(1));
    });
  });
}
