import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A dropdown list of line thickness options.
///
/// This widget displays a list of line thickness options for selection.
class LineThicknessDropdown extends StatelessWidget {
  /// Creates a list of line thickness options.
  const LineThicknessDropdown({
    required this.selectedThickness,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The currently selected line thickness.
  final double selectedThickness;

  /// Called when a line thickness option is selected.
  final ValueChanged<double> onChanged;

  /// The predefined line thickness options
  static const List<double> _thicknessOptions = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _thicknessOptions.length; i++) ...[
            _ThicknessOptionButton(
              thickness: _thicknessOptions[i],
              selected: _thicknessOptions[i] == selectedThickness,
              onTap: () => onChanged(_thicknessOptions[i]),
            ),
            if (i < _thicknessOptions.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _ThicknessOptionButton extends StatelessWidget {
  const _ThicknessOptionButton({
    required this.thickness,
    Key? key,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  final double thickness;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();

    final Widget thicknessLine = Container(
      width: 60,
      height: thickness.toDouble(),
      decoration: BoxDecoration(
        color: selected
            ? theme.lineThicknessDropdownItemSelectedLineColor
            : theme.lineThicknessDropdownItemUnselectedLineColor,
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );

    final Widget thicknessLabel = Text(
      '${thickness.toInt()} px',
      style: theme.lineThicknessDropdownItemTextStyle.copyWith(
        color: selected
            ? theme.lineThicknessDropdownItemSelectedTextColor
            : theme.lineThicknessDropdownItemUnselectedTextColor,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: selected
              ? theme.lineThicknessDropdownItemSelectedBackgroundColor
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            thicknessLabel,
            SizedBox(
              width: 40,
              child: Center(child: thicknessLine),
            ),
          ],
        ),
      ),
    );
  }
}
