import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/widgets/color_picker/dropdown_color_grid.dart';
import 'package:flutter/material.dart';

/// Shows a color picker dropdown at the specified position.
///
/// This is a stateless function that shows the dropdown and returns the selected color
/// through the onColorSelected callback.
void showColorPickerDropdown({
  required BuildContext context,
  required Offset position,
  required Color initialColor,
  required ValueChanged<Color> onColorSelected,
  BoxConstraints constraints = const BoxConstraints(maxWidth: 140, maxHeight: 320),
}) {
  // Get screen size to determine dropdown direction
  final screenSize = MediaQuery.of(context).size;
  final isBottomHalf = position.dy > screenSize.height / 2;
  
  // Create overlay entry
  late final OverlayEntry overlayEntry;
  
  // Define the overlay content
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          // Invisible full-screen touch handler to close dropdown when tapping outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => overlayEntry.remove(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // The actual dropdown
          Positioned(
            left: position.dx,
            top: isBottomHalf
                ? position.dy - constraints.maxHeight - 40
                : position.dy + 40,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(6),
              color: CoreDesignTokens.coreColorSolidSlate1100,
              child: Container(
                constraints: constraints,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownColorGrid(
                  selectedColor: initialColor,
                  onChanged: (Color selectedColor) {
                    onColorSelected(selectedColor);
                    overlayEntry.remove();
                  },
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  
  // Insert the overlay
  Overlay.of(context).insert(overlayEntry);
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