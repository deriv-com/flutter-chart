import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/animated_highlight.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final theme = Provider.of<ChartTheme>(context);

    final List<Asset> assets = (filterText == null || filterText.isEmpty)
        ? subMarket.assets
        : subMarket.assets.where((a) => a.containsText(filterText)).toList();
    return assets.isEmpty
        ? SizedBox.shrink()
        : Material(
            color: theme.base07Color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (isCategorized)
                  Container(
                    margin: const EdgeInsets.only(top: 16, left: 8),
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
        final assetItem = AssetItem(
          asset: asset,
          filterText: filterText,
          onAssetClicked: onAssetClicked,
        );

        if ((selectedItemKey?.value == asset.name || false) && isCategorized) {
          return AnimatedHighlight(
            playAfter: scrollToSelectedDuration,
            key: selectedItemKey,
            child: assetItem,
          );
        }
        return assetItem;
      }).toList();
}
