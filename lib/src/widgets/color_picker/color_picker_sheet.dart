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
          Colors.red[200],
          Colors.red[400],
          Colors.red[600],
          Colors.green[200],
          Colors.green[400],
          Colors.green[600],
          Colors.blue[200],
          Colors.blue[400],
          Colors.blue[600],
        ],
      ),
    );
  }
}
