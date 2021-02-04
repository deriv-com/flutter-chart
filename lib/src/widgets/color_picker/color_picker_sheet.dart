import 'package:deriv_chart/src/widgets/chart_bottom_sheet.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_grid.dart';
import 'package:flutter/material.dart';

/// Color picker sheet.
class ColorPickerSheet extends StatelessWidget {
  /// Creates color picker sheet.
  const ColorPickerSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChartBottomSheet(
      child: ColorGrid(
        colorOptions: [
          Colors.red[100],
          Colors.red[300],
          Colors.red[500],
          Colors.red[700],
          Colors.red[900],
          Colors.green[100],
          Colors.green[300],
          Colors.green[500],
          Colors.green[700],
          Colors.green[900],
          Colors.blue[100],
          Colors.blue[300],
          Colors.blue[500],
          Colors.blue[700],
          Colors.blue[900],
        ],
      ),
    );
  }
}
