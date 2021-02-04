import 'package:flutter/material.dart';

/// Body of a color picker.
/// Insert this into any container (pop-up, bottom sheet, etc).
class ColorGrid extends StatelessWidget {
  /// Creates a grid from given colors.
  const ColorGrid({
    @required this.colorOptions,
    Key key,
  }) : super(key: key);

  /// List of available color options.
  final List<Color> colorOptions;

  // final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: [
        for (final Color color in colorOptions)
          Container(
            width: 100,
            height: 100,
            color: color,
          ),
      ],
    );
  }
}
