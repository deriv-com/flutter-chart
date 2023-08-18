import 'package:flutter/material.dart';

/// Widget that shows the bottom indicator title.
class BottomIndicatorTitle extends StatelessWidget {
  /// Creates a widget that shows the title of the indicator.
  const BottomIndicatorTitle(this.title, this.textStyle);

  /// The title of the indicator.
  final String title;

  /// The style of the text.
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: textStyle,
      );
}
