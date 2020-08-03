import 'package:flutter/material.dart';

import '../paint/paint_loading.dart';

class LoadingPainter extends CustomPainter {
  LoadingPainter({
    @required this.loadingAnimationProgress,
    @required this.loadingRightBoundX,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  final double loadingAnimationProgress;
  final double loadingRightBoundX;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  bool get _isVisible => loadingRightBoundX > 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (_isVisible) {
      paintLoadingAnimation(
        canvas: canvas,
        size: size,
        loadingAnimationProgress: loadingAnimationProgress,
        loadingRightBoundX: loadingRightBoundX,
      );
    }
  }

  @override
  bool shouldRepaint(LoadingPainter oldDelegate) => _isVisible;

  @override
  bool shouldRebuildSemantics(LoadingPainter oldDelegate) => false;
}
