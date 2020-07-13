import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/assets_search_bar.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';
import 'package:flutter_deriv_api/basic_api/generated/active_symbols_send.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/base_api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/services/dependency_injector/injector.dart';
import 'package:flutter_deriv_api/services/dependency_injector/module_container.dart';

/// Clicked on [Asset] in market selector callback
typedef OnAssetClicked = Function(Asset asset, bool favoriteClicked);

class MarketSelector extends StatefulWidget {
  const MarketSelector({Key key, this.onAssetClicked}) : super(key: key);

  final OnAssetClicked onAssetClicked;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector> {
  @override
  void initState() {
    super.initState();
    _categorizeSymbols();
  }

  List<Market> _markets;
  List<Market> _marketsToDisplay;

  String filterText = "";

  @override
  Widget build(BuildContext context) {
    _marketsToDisplay = filterText.isEmpty
        ? _markets
        : _markets
            .where((market) =>
                market.containsAssetWithText(filterText.toLowerCase()))
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
                height: 32,
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
                  () => filterText = text,
                ),
              ),
              _marketsToDisplay == null
                  ? Container()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _marketsToDisplay.length,
                        itemBuilder: (BuildContext context, int index) =>
                            MarketItem(
                          filterText: filterText.toLowerCase(),
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

  void _categorizeSymbols() async {
    ModuleContainer().initialize(Injector.getInjector());
    await Injector.getInjector().get<BaseAPI>().connect(
          ConnectionInformation(
            appId: '1089',
            brand: 'binary',
            endpoint: 'frontend.binaryws.com',
          ),
        );

    final List<ActiveSymbol> activeSymbols =
        await ActiveSymbol.fetchActiveSymbols(const ActiveSymbolsRequest(
            activeSymbols: 'brief', productType: 'basic'));

    final List<String> marketTitles = [];

    _markets = List<Market>();

    for (final symbol in activeSymbols) {
      if (!marketTitles.contains(symbol.market)) {
        marketTitles.add(symbol.market);
        _markets.add(
          Market.fromSymbols(
            name: symbol.market,
            displayName: symbol.marketDisplayName,
            symbols:
                activeSymbols.where((e) => e.market == symbol.market).toList(),
          ),
        );
      }
    }

    setState(() {});
  }
}
