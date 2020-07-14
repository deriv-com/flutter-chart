import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/highlighted_text.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class AssetItem extends StatelessWidget {
  const AssetItem({
    Key key,
    this.asset,
    this.onAssetClicked,
    this.filterText,
  }) : super(key: key);

  final Asset asset;
  final OnAssetClicked onAssetClicked;
  final String filterText;

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
        title: HighLightedText(
          '${asset.displayName}',
          highlightText: filterText,
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
