import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/animated_highlight.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';

class SubMarketItem extends StatelessWidget {
  const SubMarketItem({
    Key key,
    this.subMarket,
    this.filterText,
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
    final List<Asset> assets = (filterText == null || filterText.isEmpty)
        ? subMarket.assets
        : subMarket.assets.where((a) => a.containsText(filterText)).toList();
    return assets.isEmpty
        ? SizedBox.shrink()
        : Material(
            // TODO(Ramin): Use Chart's theme color when its ready
            color: const Color(0xFF151717),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (isCategorized)
                  Container(
                    margin: const EdgeInsets.only(top: 16, left: 8),
                    child: Text(
                      subMarket.displayName,
                      style: // TODO(Ramin): Use Chart's theme color when its ready
                          TextStyle(
                              fontSize: 14, color: const Color(0xFF6E6E6E)),
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
