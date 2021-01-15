import 'package:flutter/material.dart';

/// Widget that shows the connection status with the given [text].
class ConnectionStatusLabel extends StatelessWidget {
  /// Creates a widget that shows the connection status with the given [text].
  const ConnectionStatusLabel({Key key, this.text}) : super(key: key);

  /// The text to display for the current connection status.
  final String text;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black26,
          ),
          child: Text(text),
        ),
      );
}
