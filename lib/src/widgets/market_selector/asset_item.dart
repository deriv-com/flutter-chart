import 'package:flutter/material.dart';

import 'models.dart';

class AssetItem extends StatelessWidget {
  const AssetItem({Key key, this.asset}) : super(key: key);

  final Asset asset;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(Icons.money_off),
        title: Text(
          asset.displayName,
          style: TextStyle(color: Color(0xFFC2C2C2)),
        ),
        trailing: Icon(Icons.star_border, color: const Color(0xFF6E6E6E)),
      );
}
