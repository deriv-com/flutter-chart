import 'package:flutter/material.dart';

/// Grid of color options for dropdown color picker.
/// 2 columns and 5 rows layout as shown in the design.
class DropdownColorGrid extends StatelessWidget {
  /// Creates a grid from given colors.
  const DropdownColorGrid({
    required this.selectedColor,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// Selected color value.
  final Color selectedColor;

  /// Called when color option is selected.
  final ValueChanged<Color> onChanged;

  /// The predefined colors for the grid (2 columns, 5 rows)
  static const List<List<Color>> _colorGrid = [
    [Color(0xFFE74C3C), Color(0xFF3498DB)], // Red, Blue
    [Color(0xFFE67E22), Color(0xFF0000FF)], // Orange, Bright Blue
    [Color(0xFFF1C40F), Color(0xFF9B59B6)], // Yellow, Purple
    [Color(0xFF2ECC71), Color(0xFF673AB7)], // Green, Deep Purple
    [Color(0xFF1ABC9C), Color(0xFFE91E63)], // Teal, Pink
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final List<Color> row in _colorGrid)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final Color color in row)
                    _ColorOptionButton(
                      color: color,
                      selected: color.value == selectedColor.value,
                      onTap: () => onChanged(color),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
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
    final Widget colorArea = Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: selected ? _wrapWithBorder(colorArea) : colorArea,
    );
  }

  Widget _wrapWithBorder(Widget child) => Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 2, color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      );
}
