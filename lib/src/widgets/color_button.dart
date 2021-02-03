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
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {},
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: _buildColorBox(),
        ),
      ),
    );
  }

  Container _buildColorBox() => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      );
}
