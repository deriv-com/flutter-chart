import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({Key key}) : super(key: key);

  // final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder(builder: ,);
    return GridView.count(crossAxisCount: null);
  }
}
