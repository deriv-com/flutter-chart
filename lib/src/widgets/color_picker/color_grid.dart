import 'package:flutter/material.dart';

/// Body of a color picker.
/// Insert this into any container (pop-up, bottom sheet, etc).
class ColorGrid extends StatelessWidget {
  /// Creates a grid from given colors.
  const ColorGrid({Key key}) : super(key: key);

  // final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder(builder: ,);
    return GridView.count(
      crossAxisCount: 4,
      children: [],
    );
  }
}
