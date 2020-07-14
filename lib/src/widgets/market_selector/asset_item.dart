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
        leading: Image(
          width: 24,
          height: 24,
          image: AssetImage(
            'assets/icons/${asset.name}.png',
            package: 'deriv_chart',
          ),
        ),
        title: Text(
          '${asset.displayName}',
          style: TextStyle(fontSize: 14, color: Color(0xFFC2C2C2)),
        ),
        onTap: () => onAssetClicked?.call(asset, false),
        trailing: IconButton(
          iconSize: 20,
          icon: Icon(
            asset.isFavorite ? Icons.star : Icons.star_border,
            color: const Color(0xFF6E6E6E),
          ),
          onPressed: () => onAssetClicked?.call(asset, true),
        ),
      );
}
