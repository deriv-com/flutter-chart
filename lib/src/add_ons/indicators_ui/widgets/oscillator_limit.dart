import 'package:flutter/material.dart';

import 'color_selector.dart';
import 'field_widget.dart';

/// A widget with a [FieldWidget] and [ColorSelector] to be used for changing Overbought/sold
/// properties on oscillator indicators.
class OscillatorLimit extends StatelessWidget {
  /// Initializes
  const OscillatorLimit({
    required this.value,
    required this.color,
    required this.onValueChanged,
    required this.onColorChanged,
    this.label = '',
    Key? key,
  }) : super(key: key);

  /// The value of the line.
  final double value;

  /// The color of the line and zones fill area.
  final Color color;

  /// Field label
  final String label;

  /// Will be called when the value has changed.
  final ValueChanged<String> onValueChanged;

  /// Will be called when the color has changed.
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          FieldWidget(
            initialValue: value.toString(),
            label: label,
            onValueChanged: onValueChanged,
          ),
          ColorSelector(currentColor: color, onColorChanged: onColorChanged),
        ],
      );
}
