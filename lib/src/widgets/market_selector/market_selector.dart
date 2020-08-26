import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_default_dark_theme.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:deriv_chart/src/widgets/custom_draggable_sheet.dart';
import 'package:deriv_chart/src/widgets/market_selector/assets_search_bar.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/no_result_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'market_item.dart';

/// Handles the tap on [Asset] in market selector.
///
/// [favouriteClicked] is true when the user has tapped on the favourite icon of the item.
typedef OnAssetClicked = Function(Asset asset, bool favouriteClicked);

/// The duration of animating the scroll to the selected item in the [MarketSelector] widget.
const scrollToSelectedDuration = Duration.zero;

class MarketSelector extends StatefulWidget {
  const MarketSelector({
    Key key,
    this.onAssetClicked,
    this.markets,
    this.selectedItem,
    this.favouriteAssets,
    this.theme,
  }) : super(key: key);

  /// It will be called when a symbol item [Asset] is tapped.
  final OnAssetClicked onAssetClicked;

  final List<Market> markets;

  final Asset selectedItem;

  /// [Optional] whenever it is null, it will be substituted with a list of assets that their [Asset.isFavourite] is true.
  final List<Asset> favouriteAssets;

  final ChartTheme theme;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector>
    with SingleTickerProviderStateMixin {
  /// List of markets after applying the [_filterText].
  List<Market> _marketsToDisplay = <Market>[];

  String _filterText = '';

  /// Is used to scroll to the selected symbol(Asset).
  GlobalObjectKey _selectedItemKey;

  ChartTheme _theme;

  @override
  void initState() {
    super.initState();

    if (widget.selectedItem != null) {
      _selectedItemKey = GlobalObjectKey(widget.selectedItem.name);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.selectedItem != null &&
          _selectedItemKey.currentState != null) {
        Scrollable.ensureVisible(
          _selectedItemKey.currentContext,
          duration: scrollToSelectedDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _theme = widget.theme ?? Theme.of(context).brightness == Brightness.dark
        ? ChartDefaultDarkTheme()
        : ChartDefaultLightTheme();
  }

  @override
  Widget build(BuildContext context) {
    _fillMarketsList();

    return CustomDraggableSheet(
      child: Provider<ChartTheme>.value(
        value: _theme,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Material(
            elevation: 8,
            color: _theme.base07Color,
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
      ),
    );
  }

  void _fillMarketsList() {
    _marketsToDisplay = _filterText.isEmpty
        ? widget.markets
        : widget.markets
            .where(
                (market) => market.containsAssetWithText(lowerCaseFilterText))
            .toList();
  }

  List<Asset> _getFavouritesList() {
    if (widget.favouriteAssets != null) {
      return _filterText.isEmpty
          ? widget.favouriteAssets
          : widget.favouriteAssets
              .map((Asset asset) => asset.containsText(lowerCaseFilterText))
              .toList();
    }

    final List<Asset> favouritesList = [];

    widget.markets?.forEach((market) {
      market.subMarkets.forEach((subMarket) {
        subMarket.assets.forEach((asset) {
          if (asset.isFavourite && asset.containsText(lowerCaseFilterText)) {
            favouritesList.add(asset);
          }
        });
      });
    });
    return favouritesList;
  }

  Widget _buildTopHandle() => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _theme.base05Color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );

  Widget _buildMarketsList() {
    final List<Asset> favouritesList = _getFavouritesList();

    return _marketsToDisplay == null
        ? Container()
        : Expanded(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      _buildFavouriteSection(favouritesList),
                      ..._marketsToDisplay
                          .map((Market market) => _buildMarketItem(market))
                    ],
                  ),
                ),
                if (_marketsToDisplay.isEmpty) NoResultPage(text: _filterText),
              ],
            ),
          );
  }

  Widget _buildFavouriteSection(List<Asset> favouritesList) => AnimatedSize(
        vsync: this,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
        child: favouritesList.isEmpty
            ? SizedBox(width: double.infinity)
            : _buildMarketItem(
                Market.fromSubMarketAssets(
                  name: 'favourites',
                  displayName: 'Favourites',
                  assets: favouritesList,
                ),
                isCategorized: false,
              ),
      );

  Widget _buildMarketItem(Market market, {bool isCategorized = true}) =>
      MarketItem(
        isSubMarketsCategorized: isCategorized,
        selectedItemKey: _selectedItemKey,
        filterText:
            market.containsText(lowerCaseFilterText) ? '' : lowerCaseFilterText,
        market: market,
        onAssetClicked: (asset, isFavouriteClicked) {
          widget.onAssetClicked?.call(asset, isFavouriteClicked);

          if (isFavouriteClicked) {
            setState(() {
              asset.toggleFavourite();
            });
          }
        },
      );

  String get lowerCaseFilterText => _filterText.toLowerCase();
}
