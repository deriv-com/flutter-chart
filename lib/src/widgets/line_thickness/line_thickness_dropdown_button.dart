import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/widgets/line_thickness/dropdown_line_thickness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../color_picker/color_picker_dropdown.dart';

class LineThicknessDropdownButton extends StatelessWidget {
  const LineThicknessDropdownButton(
      {super.key, required this.thickness, required this.onValueChanged});

  final double thickness;

  /// Will be called when a color is selected from the dropdown.
  final ValueChanged<double> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white38,
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
          showColorPickerDropdown<double>(
            context: context,
            originWidgetPosition: position,
            originWidgetSize: buttonSize,
            initialColor: thickness,
            onValueSelected: onValueChanged,
            dropdownBuilder: (
              double selectedColor,
              ValueChanged<double> onValueChanged,
            ) =>
                DropdownThicknessList(
              selectedThickness: thickness,
              onChanged: (double selectedColor) {
                onValueChanged(selectedColor);
              },
            ),
          );
        },
        child: Text(
          '${thickness.toInt()}px',
          style: const TextStyle(
            fontSize: 14,
            color: CoreDesignTokens.coreColorSolidSlate50,
            fontWeight: FontWeight.normal,
            height: 2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
