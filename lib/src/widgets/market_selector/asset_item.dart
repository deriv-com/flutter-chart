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
    this.iconFadeInDuration = const Duration(milliseconds: 50),
  }) : super(key: key);

  final Asset asset;
  final OnAssetClicked onAssetClicked;
  final String filterText;
  final Duration iconFadeInDuration;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: _buildAssetIcon(),
        title: HighLightedText(
          '${asset.displayName}',
          highlightText: filterText,
        ),
        onTap: () => onAssetClicked?.call(asset, false),
        trailing: _buildFavoriteIcon(),
      );

  IconButton _buildFavoriteIcon() => IconButton(
        icon: Icon(
          asset.isFavorite ? Icons.star : Icons.star_border,
          color: const Color(0xFF6E6E6E),
          size: 20,
        ),
        onPressed: () => onAssetClicked?.call(asset, true),
      );

  Widget _buildAssetIcon() => FadeInImage(
        width: 24,
        height: 24,
        placeholder: AssetImage(
          'assets/icons/icon_placeholder.png',
          package: 'deriv_chart',
        ),
        image: AssetImage(
          'assets/icons/${asset.name}.png',
          package: 'deriv_chart',
        ),
        fadeInDuration: iconFadeInDuration,
        fadeOutDuration: iconFadeInDuration,
      );
}
