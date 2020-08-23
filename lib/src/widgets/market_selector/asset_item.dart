import 'package:deriv_chart/src/widgets/market_selector/highlighted_text.dart';
import 'package:flutter/material.dart';

import 'market_selector.dart';
import 'models.dart';

/// A widget to show an asset (active symbol) item in the market selector.
class AssetItem extends StatelessWidget {
  const AssetItem({
    @required this.asset,
    Key key,
    this.filterText = '',
    this.onAssetClicked,
    this.iconFadeInDuration = const Duration(milliseconds: 50),
  }) : super(key: key);

  final Asset asset;
  final OnAssetClicked onAssetClicked;
  final String filterText;
  final Duration iconFadeInDuration;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.only(left: 12),
        leading: _buildAssetIcon(),
        title: HighLightedText(
          '${asset.displayName}',
          highlightText: filterText,
        ),
        onTap: () => onAssetClicked?.call(asset, false),
        trailing: _buildFavouriteIcon(),
      );

  IconButton _buildFavouriteIcon() => IconButton(
        key: ValueKey<String>('${asset.name}-fav-icon'),
        icon: Icon(
          asset.isFavourite ? Icons.star : Icons.star_border,
          color: asset.isFavourite
              ? const Color(0xFFFFAD3A)// TODO(Ramin): Use Chart's theme when its ready
              : const Color(0xFF6E6E6E),
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
