import 'package:flutter/material.dart';

/// Button that displays a color value.
class ColorButton extends StatelessWidget {
  /// Creates a button of color.
  const ColorButton({
    @required this.color,
    this.onTap,
    Key key,
  }) : super(key: key);

  /// Display color value.
  final Color color;

  /// Tap callback.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
