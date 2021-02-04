import 'package:flutter/material.dart';

/// Body of a color picker.
/// Insert this into any container (pop-up, bottom sheet, etc).
class ColorGrid extends StatelessWidget {
  /// Creates a grid from given colors.
  const ColorGrid({
    @required this.colorSwatches,
    @required this.colorShades,
    Key key,
  }) : super(key: key);

  /// List of available color swatches (rows).
  final List<MaterialColor> colorSwatches;

  /// List of color shade values (columns).
  final List<int> colorShades;

  // final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: colorShades.length,
      children: <Widget>[
        for (final MaterialColor swatch in colorSwatches)
          for (final int shade in colorShades)
            _ColorOptionButton(
              color: swatch[shade],
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
