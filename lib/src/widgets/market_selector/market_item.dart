import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'market_selector.dart';
import 'models.dart';
import 'sub_market_item.dart';

/// A widget to show a market item in market selector.
class MarketItem extends StatelessWidget {
  /// Initializes a widget to show a market item in market selector.
  const MarketItem({
    required this.market,
    required this.onAssetClicked,
    Key? key,
    this.filterText = '',
    this.selectedItemKey,
    this.isSubMarketsCategorized = true,
  }) : super(key: key);

  /// The market information of the item.
  final Market market;

  /// The text to highliht in the sub market part.
  final String filterText;

  /// Is used to scroll to the selected Asset item.
  final GlobalObjectKey? selectedItemKey;

  /// The action that appens on clicking the `AssetItem` inside the
  /// submarket part.
  final OnAssetClicked onAssetClicked;

  /// If true sub-markets will be shown with title on top of them,
  /// Otherwise under [market], will be only the list of its assets. (Suitable
  /// for favourites list).
  final bool isSubMarketsCategorized;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);
    return Container(
      color: theme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: theme.margin24Chart,
              left: theme.margin08Chart,
              bottom: theme.margin08Chart,
            ),
            child: Text(
              market.displayName,
              style: theme.textStyle(
                textStyle: theme.body2,
                color: theme.base01Color,
              ),
            ),
          ),
          ...market.subMarkets
              .map((SubMarket? subMarket) => SubMarketItem(
                    isCategorized: isSubMarketsCategorized,
                    selectedItemKey: selectedItemKey,
                    subMarket: subMarket!,
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
