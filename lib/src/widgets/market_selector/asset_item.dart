import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'closed_tag.dart';
import 'highlighted_text.dart';
import 'market_selector.dart';
import 'models.dart';
import 'symbol_icon.dart';

/// A widget to show an asset (active symbol) item in the market selector.
class AssetItem extends StatelessWidget {
  /// Initializes a widget to show an asset (active symbol) item in the market
  /// selector.
  const AssetItem({
    required this.asset,
    required this.onAssetClicked,
    Key? key,
    this.filterText = '',
    this.iconFadeInDuration = const Duration(milliseconds: 50),
  }) : super(key: key);

  /// The main asset used in the asset item.
  final Asset asset;

  /// The action that appens on clicking the [AssetItem].
  final OnAssetClicked onAssetClicked;

  /// The text to highlight in the asset item.
  final String filterText;

  /// The time which the icon fade takes to fade.
  final Duration iconFadeInDuration;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);
    return ListTile(
      contentPadding: EdgeInsets.only(left: theme.margin12Chart),
      leading: _buildAssetIcon(),
      title: _buildAssetTitle(theme),
      onTap: () => onAssetClicked.call(asset: asset, favouriteClicked: false),
      trailing: _buildFavouriteIcon(theme),
    );
  }

  Widget _buildAssetTitle(ChartTheme theme) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: HighLightedText(
              '${asset.displayName}',
              highlightText: filterText,
              style: theme.textStyle(
                textStyle: theme.body1,
                color: theme.base03Color,
              ),
            ),
          ),
          if (!asset.isOpen) ClosedTag(),
        ],
      );

  IconButton _buildFavouriteIcon(ChartTheme theme) => IconButton(
        key: ValueKey<String>('${asset.name}-fav-icon'),
        icon: Icon(
          asset.isFavourite ? Icons.star : Icons.star_border,
          color: asset.isFavourite
              ? LegacyLightThemeColors.accentYellow
              : theme.base04Color,
          size: 20,
        ),
        onPressed: () => onAssetClicked.call(
          asset: asset,
          favouriteClicked: true,
        ),
      );

  Widget _buildAssetIcon() => SymbolIcon(symbolCode: asset.name);
}
