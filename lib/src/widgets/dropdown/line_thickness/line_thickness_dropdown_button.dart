import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../show_dropdown.dart';
import 'line_thickness_dropdown.dart';

/// A button to show a line [thickness] value and open the LineThickness
/// dropdown when it's tapped.
class LineThicknessDropdownButton extends StatelessWidget {
  /// Initializes LineThicknessDropdownButton
  const LineThicknessDropdownButton({
    required this.thickness,
    required this.onValueChanged,
    super.key,
  });

  /// LineThickness
  final double thickness;

  /// Will be called when a color is selected from the dropdown.
  final ValueChanged<double> onValueChanged;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();

    return SizedBox(
      width: 32,
      height: 32,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: theme.lineThicknessDropdownButtonTextColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          // Get the button's position in the overlay
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final buttonSize = renderBox.size;

          // Calculate position at the center of the button
          final position = renderBox.localToGlobal(
              Offset(buttonSize.width / 2, buttonSize.height / 2));

          // Show the dropdown at this position
          showDropdown<double>(
            context: context,
            originWidgetPosition: position,
            originWidgetSize: buttonSize,
            initialValue: thickness,
            onValueSelected: onValueChanged,
            dropdownBuilder: (
              double selectedColor,
              ValueChanged<double> onValueChanged,
            ) =>
                LineThicknessDropdown(
              selectedThickness: thickness,
              onChanged: (double selectedColor) {
                onValueChanged(selectedColor);
              },
            ),
          );
        },
        child: Text(
          '${thickness.toInt()} px',
          style: theme.lineThicknessDropdownButtonTextStyle.copyWith(
            color: theme.lineThicknessDropdownButtonTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
