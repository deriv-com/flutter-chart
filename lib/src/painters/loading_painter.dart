import 'package:flutter/material.dart';

import '../paint/paint_loading.dart';

class LoadingPainter extends CustomPainter {
  LoadingPainter({
    @required this.loadingAnimationProgress,
    @required this.loadingRightBoundX,
  });

  final double loadingAnimationProgress;
  final double loadingRightBoundX;

  @override
  void paint(Canvas canvas, Size size) {
    paintLoadingAnimation(
      canvas: canvas,
      size: size,
      loadingAnimationProgress: loadingAnimationProgress,
      loadingRightBoundX: loadingRightBoundX,
    );
  }

  @override
  bool shouldRepaint(LoadingPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(LoadingPainter oldDelegate) => false;
}
