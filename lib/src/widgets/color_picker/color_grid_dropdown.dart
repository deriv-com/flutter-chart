import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();

    // Build the color grid from theme colors (2 columns, 4 rows)
    final List<List<Color>> colorGrid = [
      [
        theme.toolbarColorPaletteIconRed,
        theme.toolbarColorPaletteIconBlue,
      ],
      [
        theme.toolbarColorPaletteIconYellow,
        theme.toolbarColorPaletteIconSapphire,
      ],
      [
        theme.toolbarColorPaletteIconMustard,
        theme.toolbarColorPaletteIconBlueBerry,
      ],
      [
        theme.toolbarColorPaletteIconGreen,
        theme.toolbarColorPaletteIconGrape,
      ],
      [
        theme.toolbarColorPaletteIconSeaWater,
        theme.toolbarColorPaletteIconMagenta,
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(8), // 8px padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final List<Color> row in colorGrid)
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
    final ChartTheme theme = context.watch<ChartTheme>();

    final Widget colorArea = Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: theme.toolbarColorPaletteIconBorderColor,
        ),
        color: color,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: selected
          ? Stack(
              children: <Widget>[
                _buildColorOption(colorArea, theme),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.toolbarColorPaletteIconSelectedBorderColor,
                    ),
                  ),
                ),
              ],
            )
          : _buildColorOption(colorArea, theme),
    );
  }

  Widget _buildColorOption(Widget colorArea, ChartTheme theme) => SizedBox(
        height: 32, // Fixed height for color option
        width: 32, // Fixed width for color option
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              child: colorArea,
            )
          ],
        ),
      );
}
