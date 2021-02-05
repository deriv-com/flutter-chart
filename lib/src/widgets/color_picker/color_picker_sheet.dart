import 'package:deriv_chart/src/widgets/chart_bottom_sheet.dart';
import 'package:deriv_chart/src/widgets/color_picker/material_color_grid.dart';
import 'package:flutter/material.dart';

/// Color picker sheet.
class ColorPickerSheet extends StatelessWidget {
  /// Creates color picker sheet.
  const ColorPickerSheet({
    @required this.selectedColor,
    @required this.onChanged,
    Key key,
  }) : super(key: key);

  /// Selected color value.
  final Color selectedColor;

  /// Called when color option is selected.
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChartBottomSheet(
      child: MaterialColorGrid(
        colorSwatches: [
          Colors.red,
          Colors.pink,
          Colors.purple,
          Colors.lightBlue,
          Colors.lightGreen,
          Colors.yellow,
          Colors.grey,
        ],
        colorShades: const <int>[100, 300, 500, 700],
        selectedColor: selectedColor,
        onChanged: (Color selectedColor) {
          onChanged?.call(selectedColor);
          Navigator.pop(context);
        },
      ),
    );
  }
}
