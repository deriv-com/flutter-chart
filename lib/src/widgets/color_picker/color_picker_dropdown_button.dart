import 'package:deriv_chart/src/widgets/color_picker/color_picker_dropdown.dart';
import 'package:flutter/material.dart';

import 'dropdown_color_grid.dart';

/// A button that shows a color picker dropdown when tapped.
class ColorPickerDropdownButton extends StatelessWidget {
  /// Creates a color picker dropdown button.
  const ColorPickerDropdownButton({
    required this.currentColor,
    required this.onColorChanged,
    Key? key,
  }) : super(key: key);

  /// Current color.
  final Color currentColor;

  /// Will be called when a color is selected from the dropdown.
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Get the button's position in the overlay
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final buttonSize = renderBox.size;

        // Calculate position at the center of the button
        final position = renderBox
            .localToGlobal(Offset(buttonSize.width / 2, buttonSize.height / 2));

        // Show the dropdown at this position
        showColorPickerDropdown<Color>(
          context: context,
          originWidgetPosition: position,
          originWidgetSize: buttonSize,
          initialColor: currentColor,
          onValueSelected: onColorChanged,
          dropdownBuilder: (
            Color selectedColor,
            ValueChanged<Color> onColorSelected,
          ) =>
              DropdownColorGrid(
            selectedColor: selectedColor,
            onChanged: (Color selectedColor) {
              onColorSelected(selectedColor);
            },
          ),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white38,
        padding: const EdgeInsets.all(0),
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: ColorPickerIcon(color: currentColor),
    );
  }
}

/// A color picker icon widget.
class ColorPickerIcon extends StatelessWidget {
  /// Creates a color picker icon.
  const ColorPickerIcon({
    required this.color,
    Key? key,
  }) : super(key: key);

  /// The color to display.
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
}
