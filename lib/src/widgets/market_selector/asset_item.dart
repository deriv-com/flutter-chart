import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class AssetItem extends StatelessWidget {
  const AssetItem({
    Key key,
    this.asset,
    this.onAssetClicked,
  }) : super(key: key);

  final Asset asset;
  final OnAssetClicked onAssetClicked;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(Icons.money_off),
        title: Text(
          asset.displayName,
          style: TextStyle(color: Color(0xFFC2C2C2)),
        ),
        onTap: () => onAssetClicked?.call(asset, false),
        trailing: IconButton(
          icon: Icon(
            asset.isFavorite ? Icons.star : Icons.star_border,
            color: const Color(0xFF6E6E6E),
          ),
          onPressed: () => onAssetClicked?.call(asset, true),
        ),
      );
}
