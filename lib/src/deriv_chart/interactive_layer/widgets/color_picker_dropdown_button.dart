import 'package:deriv_chart/src/widgets/color_picker/color_picker_dropdown.dart';
import 'package:flutter/material.dart';

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
        final position = renderBox.localToGlobal(Offset.zero);
        
        // Show the dropdown at this position
        showColorPickerDropdown(
          context: context,
          position: position,
          initialColor: currentColor,
          onColorSelected: onColorChanged,
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
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: _buildColorBox(),
        ),
      ),
    );
  }

  Container _buildColorBox() => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}