import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animated_highlight.dart';
import 'asset_item.dart';
import 'market_selector.dart';
import 'models.dart';

/// A widget to show a sub-market item under a market.
class SubMarketItem extends StatelessWidget {
  /// Initializes a widget to show a sub-market item under a market.
  const SubMarketItem({
    required this.subMarket,
    Key? key,
    this.filterText = '',
    this.selectedItemKey,
    required this.onAssetClicked,
    this.isCategorized = true,
  }) : super(key: key);

  /// The sub-market to be shown in the widget.
  final SubMarket subMarket;

  /// the filter text to be passed to the asset of the sub-market.
  final String filterText;

  /// The key to be passed to the `AnimatedHighlight` widget to highlight the
  /// sub-maket item.
  final GlobalObjectKey? selectedItemKey;

  /// The action that appens on clicking the [AssetItem].
  final OnAssetClicked onAssetClicked;

  /// Whether the [SubMarketItem] is  categorized or not.
  final bool isCategorized;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);

    final List<Asset?> assets = filterText.isEmpty
        ? subMarket.assets
        : subMarket.assets
            .where((Asset? a) => a != null && a.containsText(filterText))
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
                      top: theme.margin16Chart,
                      left: theme.margin08Chart,
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

  List<Widget> _buildAssetsList(List<Asset?> assets) =>
      assets.where((Asset? asset) => asset != null).map((Asset? asset) {
        final AssetItem assetItem = AssetItem(
          asset: asset!,
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
