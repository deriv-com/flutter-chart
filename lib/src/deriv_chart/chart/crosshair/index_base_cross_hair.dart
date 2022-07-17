import 'package:deriv_chart/src/deriv_chart/chart/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_dot_painter.dart';
import 'crosshair_line_painter.dart';

/// A Cross-hair widget to work with index of data rather than epoch.
class IndexBaseCrossHair extends StatefulWidget {
  /// initializes [IndexBaseCrossHair].
  const IndexBaseCrossHair({
    required this.quoteToY,
    required this.indexToX,
    required this.xToIndex,
    required this.ticks,
    this.enabled = false,
    this.pipSize = 4,
    this.crossHairContentPadding = 4,
    this.crossHairTextStyle = TextStyles.overLine,
    Key? key,
  }) : super(key: key);

  /// Conversion function to convert quote to canvas Y.
  final QuoteToY quoteToY;

  /// Conversion function to convert index to canvas X.
  final double Function(int) indexToX;

  /// Conversion function to convert canvas X to index.
  final double Function(double x) xToIndex;

  /// The list of ticks to show it's ticks info on cross-hair.
  final List<Tick> ticks;

  /// Number of decimal points when showing price of a tick.
  final int pipSize;

  /// Whether cross-hair is enabled or not.
  final bool enabled;

  /// Inner padding for cross hair details card.
  final double crossHairContentPadding;

  /// Text style for cross hair detail text.
  final TextStyle crossHairTextStyle;

  @override
  _IndexBaseCrossHairState createState() => _IndexBaseCrossHairState();
}

class _IndexBaseCrossHairState extends State<IndexBaseCrossHair>
    with SingleTickerProviderStateMixin {
  int? _crossHairIndex;
  Size? _crossHairDetailSize;
  late GestureManagerState gestureManager;

  late AnimationController _crossHairAnimationController;
  late Animation<double> _crossHairFadeAnimation;

  @override
  void initState() {
    super.initState();

    _crossHairAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _crossHairFadeAnimation = CurvedAnimation(
      parent: _crossHairAnimationController,
      curve: Curves.easeInOut,
    );

    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onLongPressStart)
      ..registerCallback(_onLongPressUpdate)
      ..registerCallback(_onLongPressEnd);

    _updateCrossHairDetailSize();
  }

  @override
  void didUpdateWidget(covariant IndexBaseCrossHair oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCrossHairDetailSize();
  }

  void _updateCrossHairDetailSize() {
    if (widget.ticks.isNotEmpty) {
      _crossHairDetailSize = _calculateTextSize(
            widget.ticks.first.quote.toStringAsFixed(widget.pipSize),
            widget.crossHairTextStyle,
          ) +
          Offset(
            widget.crossHairContentPadding,
            widget.crossHairContentPadding,
          );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (_crossHairIndex == null) {
            return const SizedBox.shrink();
          }

          return FadeTransition(
            opacity: _crossHairFadeAnimation,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  top: widget.quoteToY(widget.ticks[_crossHairIndex!].quote),
                  left: widget.indexToX(_crossHairIndex!),
                  child: CustomPaint(
                    size: Size(1, constraints.maxHeight),
                    painter: const CrosshairDotPainter(),
                  ),
                ),
                if (_crossHairDetailSize != null)
                  AnimatedPositioned(
                    left: _getCrossHairDetailCardLeftPosition(
                      _crossHairDetailSize!.width,
                      _crossHairIndex!,
                      constraints.maxWidth,
                    ),
                    duration: const Duration(milliseconds: 100),
                    child: Column(
                      children: <Widget>[
                        _buildCrossHairDetail(),
                        CustomPaint(
                          size: Size(1, constraints.maxHeight),
                          painter: const CrosshairLinePainter(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      );

  /// Calculates a left position for cross hair details card to keep it inside
  /// Chart's area.
  double _getCrossHairDetailCardLeftPosition(
    double crossHairDetailWidth,
    int crossHairIndex,
    double chartWidth,
  ) {
    final double leftPosition =
        widget.indexToX(crossHairIndex) - crossHairDetailWidth / 2;

    if (leftPosition < 0) {
      return 0;
    } else if (leftPosition + crossHairDetailWidth > chartWidth) {
      return chartWidth - crossHairDetailWidth;
    }

    return leftPosition;
  }

  Size _calculateTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout();
    return textPainter.size;
  }

  Widget _buildCrossHairDetail() => _crossHairDetailSize != null
      ? Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.all(widget.crossHairContentPadding),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Color(0xFF323738),
            ),
            child: Text(
              '''${widget.ticks[_crossHairIndex!].quote.toStringAsFixed(widget.pipSize)}''',
              style: widget.crossHairTextStyle,
            ),
          ),
        )
      : const SizedBox.shrink();

  void _onLongPressStart(LongPressStartDetails details) {
    if (!widget.enabled) {
      return;
    }
    final Offset position = details.localPosition;
    _updateCrossHairToPosition(position.dx);
    _crossHairAnimationController.forward();
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    if (!widget.enabled) {
      return;
    }
    final Offset position = details.localPosition;
    _updateCrossHairToPosition(position.dx);
  }

  void _updateCrossHairToPosition(double x) => setState(
        () => _crossHairIndex = findClosestIndex(
          widget.xToIndex(x),
          widget.ticks,
        ),
      );

  Future<void> _onLongPressEnd(LongPressEndDetails details) async {
    if (!widget.enabled) {
      return;
    }
    await _crossHairAnimationController.reverse(from: 1);
    setState(() => _crossHairIndex = null);
  }

  @override
  void dispose() {
    gestureManager
      ..removeCallback(_onLongPressStart)
      ..removeCallback(_onLongPressUpdate)
      ..removeCallback(_onLongPressEnd);
    super.dispose();
  }
}
