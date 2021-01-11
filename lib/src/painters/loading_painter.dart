import 'package:flutter/material.dart';

import '../paint/paint_loading.dart';

/// The painter that paints loading on the given loading area
class LoadingPainter extends CustomPainter {
  /// Initializes the painter that paints loading on the given loading area
  LoadingPainter({
    @required this.loadingAnimationProgress,
    @required this.loadingRightBoundX,
  });

  /// The progress shown in `double` for the loading.
  final double loadingAnimationProgress;

  /// The right bound of the loading area in X axis.
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
