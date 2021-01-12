import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animated_highlight.dart';
import 'asset_item.dart';
import 'market_selector.dart';
import 'models.dart';

/// A widget to show a sub-market item under a market.
class SubMarketItem extends StatelessWidget {
  const SubMarketItem({
    @required this.subMarket,
    Key key,
    this.filterText = '',
    this.selectedItemKey,
    this.onAssetClicked,
    this.isCategorized = true,
  }) : super(key: key);

  final SubMarket subMarket;
  final String filterText;
  final GlobalObjectKey selectedItemKey;
  final OnAssetClicked onAssetClicked;
  final bool isCategorized;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);

    final List<Asset> assets = (filterText == null || filterText.isEmpty)
        ? subMarket.assets
        : subMarket.assets
            .where((Asset a) => a.containsText(filterText))
            .toList();
    return assets.isEmpty
        ? const SizedBox.shrink()
        : Material(
            color: theme.base07Color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (isCategorized)
                  Container(
                    margin: EdgeInsets.only(
                      top: theme.margin16,
                      left: theme.margin08,
                    ),
                    child: Text(
                      subMarket.displayName,
                      style: theme.textStyle(
                        textStyle: theme.body1,
                        color: theme.base04Color,
                      ),
                    ),
                  ),
                ..._buildAssetsList(assets)
              ],
            ),
          );
  }

  List<Widget> _buildAssetsList(List<Asset> assets) =>
      assets.map((Asset asset) {
        final AssetItem assetItem = AssetItem(
          asset: asset,
          filterText: filterText,
          onAssetClicked: onAssetClicked,
        );

        if (selectedItemKey?.value == asset.name || false) {
          return AnimatedHighlight(
            playAfter: scrollToSelectedDuration,
            key: isCategorized ? selectedItemKey : null,
            child: assetItem,
          );
        }
        return assetItem;
      }).toList();
}
