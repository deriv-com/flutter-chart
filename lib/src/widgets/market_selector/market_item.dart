import 'package:flutter/material.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/sub_market_item.dart';
import 'market_selector.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({
    Key key,
    this.market,
    this.filterText,
    this.onAssetClicked,
    this.selectedItemKey,
    this.isSubMarketsCategorized = true,
  }) : super(key: key);

  final Market market;
  final String filterText;
  final GlobalObjectKey selectedItemKey;
  final OnAssetClicked onAssetClicked;
  final bool isSubMarketsCategorized;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF0E0E0E),
        // TODO(Ramin): Use Chart's theme when its ready
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 24, left: 8, bottom: 8),
              child: Text(
                market.displayName,
                // TODO(Ramin): Use Chart's theme when its ready
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ...market.subMarkets
                .map((e) => SubMarketItem(
                      isCategorized: isSubMarketsCategorized,
                      selectedItemKey: selectedItemKey,
                      subMarket: e,
                      filterText: filterText,
                      onAssetClicked: onAssetClicked,
                    ))
                .toList(),
          ],
        ),
      );
}
