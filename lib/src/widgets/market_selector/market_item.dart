import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/sub_market_item.dart';
import 'package:provider/provider.dart';
import 'market_selector.dart';

/// A widget to show a market item in market selector
class MarketItem extends StatelessWidget {
  const MarketItem({
    Key key,
    @required this.market,
    this.filterText = '',
    this.onAssetClicked,
    this.selectedItemKey,
    this.isSubMarketsCategorized = true,
  }) : super(key: key);

  final Market market;

  final String filterText;

  /// Is used to scroll to the selected Asset item
  final GlobalObjectKey selectedItemKey;

  final OnAssetClicked onAssetClicked;

  /// If true sub-markets will be shown with title on top of them,
  /// Otherwise under [market], will be only the list of its assets. (Suitable for favourites list)
  final bool isSubMarketsCategorized;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ChartTheme>(context);
    return Container(
      color: theme.base08Color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 24, left: 8, bottom: 8),
            child: Text(
              market.displayName ?? '',
              style: theme.textStyle(
                textStyle: theme.body2,
                color: theme.base01Color,
              ),
            ),
          ),
          ...market.subMarkets
              .map((SubMarket subMarket) => SubMarketItem(
                    isCategorized: isSubMarketsCategorized,
                    selectedItemKey: selectedItemKey,
                    subMarket: subMarket,
                    filterText:
                        subMarket.containsText(filterText) ? '' : filterText,
                    onAssetClicked: onAssetClicked,
                  ))
              .toList(),
        ],
      ),
    );
  }
}
