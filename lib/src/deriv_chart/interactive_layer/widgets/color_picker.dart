import 'package:flutter/material.dart';

import 'package:deriv_chart/src/widgets/color_picker/color_picker_sheet.dart';

/// Color picker widget.
class ColorPicker extends StatelessWidget {
  /// Initializes
  const ColorPicker({
    required this.currentColor,
    required this.onColorChanged,
    Key? key,
  }) : super(key: key);

  /// Current color.
  final Color currentColor;

  /// Will be called when a color is selected from [ColorPickerSheet].
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) => _ColorPickerIcon(
        color: currentColor,
        onTap: () {
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) => ColorPickerSheet(
              selectedColor: currentColor,
              onChanged: onColorChanged,
            ),
          );
        },
      );
}

class _ColorPickerIcon extends StatelessWidget {
  /// Creates a Color picker icon.
  const _ColorPickerIcon({
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  /// Display color value.
  final Color color;

  /// Tap callback.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
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

  Container _buildColorBox() => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}
