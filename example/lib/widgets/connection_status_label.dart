import 'package:flutter/material.dart';

class ConnectionStatusLabel extends StatelessWidget {
  const ConnectionStatusLabel({Key key, this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black26,
        ),
        child: Text(text),
      );
}
