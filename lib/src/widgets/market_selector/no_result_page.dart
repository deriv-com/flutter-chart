import 'package:flutter/material.dart';

class NoResultPage extends StatelessWidget {
  const NoResultPage({Key key, this.text = ''}) : super(key: key);

  final text;

  // TODO(ramin): use theme colors once its ready
  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints.expand(),
        color: const Color(0xFF0E0E0E),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 68,
                color: const Color(0xFF3e3e3e),
              ),
              SizedBox(height: 30),
              Text(
                'No results for \"$text\"',
                style: TextStyle(fontSize: 14, color: const Color(0xFFC2C2C2)),
              ),
              SizedBox(height: 8),
              Text(
                'Try checking your spelling or use a different term',
                style: TextStyle(fontSize: 12, color: const Color(0xFF6E6E6E)),
              ),
            ],
          ),
        ),
      );
}
