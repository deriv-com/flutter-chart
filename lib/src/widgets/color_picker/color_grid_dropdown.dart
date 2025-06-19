import 'package:flutter/material.dart';

/// Grid of color options for dropdown color picker.
/// 2 columns and 5 rows layout as shown in the design.
class ColorGridDropdown extends StatelessWidget {
  /// Creates a grid from given colors.
  const ColorGridDropdown({
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
      padding: const EdgeInsets.all(8), // 8px padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final List<Color> row in _colorGrid)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              // 6px vertical padding
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < row.length; i++) ...[
                    _ColorOptionButton(
                      color: row[i],
                      selected: row[i].value == selectedColor.value,
                      onTap: () => onChanged(row[i]),
                    ),
                    if (i < row.length - 1) const SizedBox(width: 4)
                  ],
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
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          // TODO(NA): use color from core design tokens when the token is there.
          color: const Color(0x29000000),
          width: 2,
        ),
        color: color,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: selected
          ? Stack(
              children: <Widget>[
                _buildColorOption(colorArea),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            )
          : _buildColorOption(colorArea),
    );
  }

  Widget _buildColorOption(Widget colorArea) => SizedBox(
        height: 32, // Fixed height for color option
        width: 32, // Fixed width for color option
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                // border: selected ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: colorArea,
            )
          ],
        ),
      );
}
