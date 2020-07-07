import 'package:flutter/material.dart';

class SymbolItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(Icons.money_off),
        title: Text(
          'Volatility Index 25',
          style: TextStyle(color: Color(0xFFC2C2C2)),
        ),
        trailing: Icon(Icons.star_border),
        onTap: () {},
      );
}
