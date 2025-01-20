import 'package:deriv_chart/src/misc/extensions.dart';
import 'package:flutter/material.dart';

/// Grid of material color options.
/// Columns are shades and rows are color swatches.
///
/// Serves as a body of a color picker.
/// Insert this into any container (pop-up, bottom sheet, etc).
class MaterialColorGrid extends StatelessWidget {
  /// Creates a grid from given colors.
  const MaterialColorGrid({
    required this.selectedColor,
    required this.onChanged,
    this.colorSwatches = const <MaterialColor>[
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.yellow,
      Colors.grey,
    ],
    this.colorShades = const <int>[100, 300, 500, 700],
    Key? key,
  }) : super(key: key);

  /// List of available color swatches (rows).
  final List<MaterialColor> colorSwatches;

  /// List of color shade values (columns).
  final List<int> colorShades;

  /// Selected color value.
  final Color selectedColor;

  /// Called when color option is selected.
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) => GridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: colorShades.length,
        children: <Widget>[
          for (final MaterialColor swatch in colorSwatches)
            for (final int shade in colorShades)
              _ColorOptionButton(
                color: swatch[shade]!,
                selected: swatch[shade]!.toInt32 == selectedColor.toInt32,
                onTap: () {
                  onChanged.call(swatch[shade]!);
                },
              ),
        ],
      );
}

class _ColorOptionButton extends StatelessWidget {
  const _ColorOptionButton({
    required this.color,
    Key? key,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget colorArea = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: selected ? _wrapWithBorder(colorArea) : colorArea,
      ),
    );
  }

  Widget _wrapWithBorder(Widget child) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 4, color: color),
        ),
        child: child,
      );
}
