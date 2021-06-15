import 'package:flutter/material.dart';

/// A dropdown menu with label.
class DropdownMenu<T> extends StatelessWidget {
  /// Initializes
  const DropdownMenu({
    @required this.initialValue,
    @required this.items,
    this.label = '',
    this.labelForItem,
    this.onItemSelected,
    Key key,
  }) : super(key: key);

  /// Menu label.
  final String label;

  /// Initial value.
  final T initialValue;

  /// Dropdown items.
  final List<T> items;

  /// Will be called get the appropriate title for the item [T].
  ///
  /// If null if will use the [T.toString()] as the title.
  final String Function(T item) labelForItem;

  /// Will be called whenever a dropdown item is selected.
  final ValueChanged<T> onItemSelected;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<T>(
            value: initialValue,
            items: items
                .map<DropdownMenuItem<T>>((T type) => DropdownMenuItem<T>(
                      value: type,
                      child: Text(
                        labelForItem == null
                            ? type.toString()
                            : labelForItem(type),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ))
                .toList(),
            onChanged: onItemSelected,
          ),
        ],
      );
}
