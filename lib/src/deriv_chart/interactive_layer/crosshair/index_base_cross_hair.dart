import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/large_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/small_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_dot_painter.dart';

/// A Cross-hair widget to work with index of data rather than epoch.
class IndexBaseCrossHair extends StatefulWidget {
  /// initializes [IndexBaseCrossHair].
  const IndexBaseCrossHair({
    required this.quoteToY,
    required this.indexToX,
    required this.xToIndex,
    required this.ticks,
    required this.crosshairVariant,
    this.enabled = false,
    this.pipSize = 4,
    this.crossHairContentPadding = 4,
    this.crossHairTextStyle = TextStyles.overLine,
    this.crossHairTransitionAnimationDuration =
        const Duration(milliseconds: 100),
    this.onTap,
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

  /// The animation duration of the cross hair when jumping from one tick to
  /// another while user kept long press and moving between ticks.
  final Duration crossHairTransitionAnimationDuration;

  /// A temporary solution for the issue when we wrap the worm chart with
  /// GestureDetector to have the onTap.
  final VoidCallback? onTap;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

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

  Offset? _longPressPosition;

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
      ..registerCallback(_onTapUp)
      ..registerCallback(_onLongPressStart)
      ..registerCallback(_onLongPressUpdate)
      ..registerCallback(_onLongPressEnd);

    _updateCrossHairDetailSize();
  }

  @override
  void didUpdateWidget(covariant IndexBaseCrossHair oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCrossHairDetailSize();
    if (_longPressPosition != null) {
      // User has hold the long press during the update transition of the widget
      _updateCrossHairToPosition(_longPressPosition!.dx);
    }
  }

  void _updateCrossHairDetailSize() {
    if (widget.ticks.isNotEmpty) {
      _crossHairDetailSize = _calculateTextSize(
            widget.ticks.first.quote.toStringAsFixed(widget.pipSize),
            widget.crossHairTextStyle,
          ) +
          Offset(
            // left and right.
            widget.crossHairContentPadding * 2,
            // top and bottom.
            widget.crossHairContentPadding * 2,
          );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final ChartTheme theme = context.read<ChartTheme>();
          final Color dotColor = theme.currentSpotDotColor;
          final Color dotEffect = theme.currentSpotDotEffect;

          if (_crossHairIndex == null) {
            return const SizedBox.shrink();
          }

          return FadeTransition(
            opacity: _crossHairFadeAnimation,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AnimatedPositioned(
                  duration: widget.crossHairTransitionAnimationDuration,
                  top: widget.quoteToY(widget.ticks[_crossHairIndex!].quote),
                  left: widget.indexToX(_crossHairIndex!),
                  child: CustomPaint(
                    size: Size(1, constraints.maxHeight),
                    painter:
                        widget.crosshairVariant == CrosshairVariant.smallScreen
                            ? CrosshairDotPainter(
                                dotColor: dotColor, dotBorderColor: dotEffect)
                            : null,
                  ),
                ),
                if (_crossHairDetailSize != null) ...<Widget>[
                  AnimatedPositioned(
                    left: _getCrossHairDetailCardLeftPosition(
                      _crossHairDetailSize!.width,
                      _crossHairIndex!,
                      constraints.maxWidth,
                    ),
                    duration: widget.crossHairTransitionAnimationDuration,
                    child: _buildCrossHairDetail(),
                  ),
                  AnimatedPositioned(
                    left: widget.indexToX(_crossHairIndex!),
                    top: _crossHairDetailSize!.height,
                    duration: widget.crossHairTransitionAnimationDuration,
                    child: CustomPaint(
                      size: Size(
                        1,
                        constraints.maxHeight - _crossHairDetailSize!.height,
                      ),
                      painter: widget.crosshairVariant ==
                              CrosshairVariant.smallScreen
                          ? SmallScreenCrosshairLinePainter(
                              theme: theme,
                            )
                          : LargeScreenCrosshairLinePainter(
                              theme: theme,
                            ),
                    ),
                  )
                ]
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
    _longPressPosition = details.localPosition;
    _updateCrossHairToPosition(_longPressPosition!.dx);
    _crossHairAnimationController.forward();
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    if (!widget.enabled) {
      return;
    }
    _longPressPosition = details.localPosition;
    _updateCrossHairToPosition(_longPressPosition!.dx);
  }

  void _updateCrossHairToPosition(double x) {
    int crossHairIndex = _getCrossHairIndexFromTouchPosition(x);

    // Keep cross hair index inside chart view port.
    double crossHairX = widget.indexToX(crossHairIndex);

    while (crossHairX < 0) {
      crossHairIndex++;
      crossHairX = widget.indexToX(crossHairIndex);
    }

    setState(() => _crossHairIndex = crossHairIndex);
  }

  int _getCrossHairIndexFromTouchPosition(double touchX) => findClosestIndex(
        widget.xToIndex(touchX),
        widget.ticks,
      );

  Future<void> _onLongPressEnd(LongPressEndDetails details) async {
    if (!widget.enabled) {
      return;
    }
    await _crossHairAnimationController.reverse(from: 1);
    setState(() => _crossHairIndex = null);
  }

  void _onTapUp(TapUpDetails tapUpDetails) {
    widget.onTap?.call();
  }

  @override
  void dispose() {
    gestureManager
      ..removeCallback(_onTapUp)
      ..removeCallback(_onLongPressStart)
      ..removeCallback(_onLongPressUpdate)
      ..removeCallback(_onLongPressEnd);
    super.dispose();
  }
}
