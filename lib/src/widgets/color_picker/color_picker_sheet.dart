import 'package:deriv_chart/src/widgets/color_picker/color_grid.dart';
import 'package:deriv_chart/src/widgets/custom_draggable_sheet.dart';
import 'package:flutter/material.dart';

class ColorPickerSheet extends StatelessWidget {
  const ColorPickerSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDraggableSheet(
      child: ColorGrid(),
    );
  }
}
