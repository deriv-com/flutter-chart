import 'package:flutter/material.dart';

import '../paint/paint_loading.dart';

class LoadingPainter extends CustomPainter {
  LoadingPainter({
    @required this.loadingAnimationProgress,
    @required this.loadingRightBoundX,
  });

  final double loadingAnimationProgress;
  final double loadingRightBoundX;

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
