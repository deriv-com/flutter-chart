import 'package:deriv_chart/src/painters/loading_painter.dart';
import 'package:flutter/material.dart';

/// Area to show the loading animation in.
class LoadingAnimationArea extends StatefulWidget {
  /// Creates loading animation area.
  const LoadingAnimationArea({
    required this.loadingRightBoundX,
    Key? key,
  }) : super(key: key);

  ///  The right bound in the chart area when loading area is showing.
  final double loadingRightBoundX;

  @override
  _LoadingAnimationAreaState createState() => _LoadingAnimationAreaState();
}

class _LoadingAnimationAreaState extends State<LoadingAnimationArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingAnimationController;

  bool get _isVisible => widget.loadingRightBoundX > 0;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: AnimatedBuilder(
        animation: _loadingAnimationController,
        builder: (BuildContext context, _) {
          return CustomPaint(
            painter: LoadingPainter(
              loadingAnimationProgress: _loadingAnimationController.value,
              loadingRightBoundX: widget.loadingRightBoundX,
            ),
          );
        },
      ),
    );
  }
}
