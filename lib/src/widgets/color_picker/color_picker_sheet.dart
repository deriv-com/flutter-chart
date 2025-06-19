import 'package:deriv_chart/src/widgets/chart_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'material_color_grid.dart';

/// Color picker sheet.
class ColorPickerSheet extends StatefulWidget {
  /// Creates color picker sheet.
  const ColorPickerSheet({
    required this.selectedColor,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// Selected color value.
  final Color selectedColor;

  /// Called when color option is selected.
  final ValueChanged<Color> onChanged;

  @override
  _ColorPickerSheetState createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) => ChartBottomSheet(
        child: MaterialColorGrid(
          selectedColor: _selectedColor ?? widget.selectedColor,
          onChanged: (Color selectedColor) {
            setState(() {
              _selectedColor = selectedColor;
            });
            widget.onChanged.call(selectedColor);
            Navigator.pop(context);
          },
        ),
      );
}
