import 'package:flutter/material.dart';

/// Field widget
class FieldWidget extends StatelessWidget {
  /// Initializes
  const FieldWidget({
    @required this.initialValue,
    this.onValueChanged,
    this.label = '',
    Key key,
  }) : super(key: key);

  /// Period's initial value
  final String initialValue;

  /// Will be called whenever the field's value has changed.
  final Function(String) onValueChanged;

  /// The label of the field.
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Text(label, style: const TextStyle(fontSize: 10)),
      const SizedBox(width: 4),
      SizedBox(
        width: 20,
        child: TextFormField(
          style: const TextStyle(fontSize: 10),
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          onChanged: onValueChanged,
        ),
      ),
    ],
  );
}
