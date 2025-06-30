import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/chart_theme.dart';

/// A widget that applies a glassy blur effect.
class GlassyBlurEffectWidget extends StatelessWidget {
  /// Creates a widget that applies a glassy blur effect.
  const GlassyBlurEffectWidget({required this.child, super.key});

  /// The child widget to apply the glassy blur effect to.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: theme.crosshairInformationBoxContainerGlassBackgroundBlur,
          sigmaY: theme.crosshairInformationBoxContainerGlassBackgroundBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.floatingMenuContainerGlassColor),
          child: child,
        ),
      ),
    );
  }
}
