import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';

/// Widget that shows the bottom indicator title.
class BottomIndicatorTitle extends StatelessWidget {
  /// Creates a widget that shows the title of the indicator.
  const BottomIndicatorTitle(this.title);

  /// The title of the indicator.
  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: TextStyles.body1Bold);
}
