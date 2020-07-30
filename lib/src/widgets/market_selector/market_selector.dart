import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/custom_draggable_sheet.dart';
import 'package:deriv_chart/src/widgets/market_selector/assets_search_bar.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:flutter/material.dart';

/// Clicked on [Asset] in market selector callback.
///
/// [favoriteClicked] is true when user has clicked on favorite icon of the item.
typedef OnAssetClicked = Function(Asset asset, bool favoriteClicked);

/// The animation duration which will take to scroll to selected item in MarketSelector
const scrollToSelectedDuration = Duration(milliseconds: 600);

class MarketSelector extends StatefulWidget {
  const MarketSelector({
    Key key,
    this.onAssetClicked,
    this.markets,
    this.selectedItem,
  }) : super(key: key);

  /// Will be called when a symbol item [Asset] is clicked.
  final OnAssetClicked onAssetClicked;

  final List<Market> markets;

  final Asset selectedItem;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector> {
  List<Market> _markets;

  /// List of markets after applying the [_filterText].
  List<Market> _marketsToDisplay;

  String _filterText = "";

  /// Is used to scroll to the selected symbol(Asset).
  GlobalObjectKey _selectedItemKey;

  @override
  void initState() {
    super.initState();

    _markets = widget.markets;

    _selectedItemKey = GlobalObjectKey(widget.selectedItem.name);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Scrollable.ensureVisible(
        _selectedItemKey.currentContext,
        duration: scrollToSelectedDuration,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _marketsToDisplay = _filterText.isEmpty
        ? _markets
        : _markets
            .where((market) =>
                market.containsAssetWithText(_filterText.toLowerCase()))
            .toList();

    return CustomDraggableSheet(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Material(
          elevation: 8, // TODO(Ramin): Use Chart's theme when its ready
          color: Color(0xFF151717),
          child: Column(
            children: <Widget>[
              _buildTopHandle(),
              AssetsSearchBar(
                onSearchTextChanged: (String text) =>
                    setState(() => _filterText = text),
              ),
              _buildMarketsList(),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildTopHandle() => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              // TODO(Ramin): Use Chart's theme when its ready
              color: const Color(0xFF3E3E3E),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );

  Widget _buildMarketsList() => _marketsToDisplay == null
      ? Container()
      : Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ..._marketsToDisplay.map((Market market) => MarketItem(
                      selectedItemKey: _selectedItemKey,
                      filterText: _filterText.toLowerCase(),
                      market: market,
                      onAssetClicked: (asset, isFavoriteClicked) {
                        widget.onAssetClicked?.call(
                          asset,
                          isFavoriteClicked,
                        );
                        if (isFavoriteClicked) {
                          setState(() {
                            asset.toggleFavorite();
                          });
                        }
                      },
                    ))
              ],
            ),
          ),
        );
}
