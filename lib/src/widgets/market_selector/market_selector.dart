import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/assets_search_bar.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:flutter/material.dart';

/// Clicked on [Asset] in market selector callback.
///
/// [favoriteClicked] is true when user has clicked on favorite icon of the item.
typedef OnAssetClicked = Function(Asset asset, bool favoriteClicked);

class MarketSelector extends StatefulWidget {
  const MarketSelector({
    Key key,
    this.onAssetClicked,
    this.markets,
  }) : super(key: key);

  /// Will be called when a symbol item [Asset] is clicked.
  final OnAssetClicked onAssetClicked;
  final List<Market> markets;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector> {
  /// List of markets after applying the [_filterText].
  List<Market> _marketsToDisplay;

  String _filterText = "";

  @override
  Widget build(BuildContext context) {
    _marketsToDisplay = _filterText.isEmpty
        ? widget.markets
        : widget.markets
            .where((market) =>
                market.containsAssetWithText(_filterText.toLowerCase()))
            .toList();

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Material(
          elevation: 8,
          color: Color(0xFF151717),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E3E3E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              AssetsSearchBar(
                onSearchTextChanged: (String text) => setState(
                  () => _filterText = text,
                ),
              ),
              _marketsToDisplay == null
                  ? Container()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _marketsToDisplay.length,
                        itemBuilder: (BuildContext context, int index) =>
                            MarketItem(
                          filterText: _filterText.toLowerCase(),
                          market: _marketsToDisplay[index],
                          onAssetClicked: widget.onAssetClicked,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
