import 'package:deriv_chart/src/widgets/chart_bottom_sheet.dart';
import 'package:deriv_chart/src/widgets/color_picker/material_color_grid.dart';
import 'package:flutter/material.dart';

/// Color picker sheet.
class ColorPickerSheet extends StatelessWidget {
  /// Creates color picker sheet.
  const ColorPickerSheet({Key key}) : super(key: key);

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
        selectedColor: Colors.red[100],
        onChanged: (Color selectedColor) {
          print('>>> $selectedColor');
        },
      ),
    );
  }
}
