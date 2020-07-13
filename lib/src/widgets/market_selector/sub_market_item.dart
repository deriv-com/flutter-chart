import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';

class SubMarketItem extends StatelessWidget {
  const SubMarketItem({
    Key key,
    this.subMarket,
    this.filterText,
    this.onAssetClicked,
  }) : super(key: key);

  final SubMarket subMarket;
  final String filterText;
  final OnAssetClicked onAssetClicked;

  @override
  Widget build(BuildContext context) {
    final List<Asset> assets = (filterText == null || filterText.isEmpty)
        ? subMarket.assets
        : subMarket.assets
            .where((a) => a.displayName.toLowerCase().contains(filterText))
            .toList();
    return assets.isEmpty
        ? SizedBox.shrink()
        : Material(
            color: const Color(0xFF151717),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 16, left: 8),
                  child: Text(
                    subMarket.displayName,
                    style:
                        TextStyle(fontSize: 14, color: const Color(0xFF6E6E6E)),
                  ),
                ),
                ...assets
                    .map((Asset asset) => AssetItem(
                          asset: asset,
                          onAssetClicked: onAssetClicked,
                        ))
                    .toList()
              ],
            ),
          );
  }
}
