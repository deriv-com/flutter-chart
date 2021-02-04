import 'package:flutter/material.dart';

/// Body of a color picker.
/// Insert this into any container (pop-up, bottom sheet, etc).
class ColorGrid extends StatelessWidget {
  /// Creates a grid from given colors.
  const ColorGrid({
    @required this.colorOptions,
    Key key,
  }) : super(key: key);

  /// List of available color options.
  final List<Color> colorOptions;

  // final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 5,
      children: <Widget>[
        for (final Color color in colorOptions)
          _ColorOptionButton(
            color: color,
          ),
      ],
    );
  }
}

class _ColorOptionButton extends StatelessWidget {
  const _ColorOptionButton({
    Key key,
    this.color,
    this.onTap,
  }) : super(key: key);

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
