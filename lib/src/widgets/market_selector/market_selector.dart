import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/symbol_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';
import 'package:flutter_deriv_api/basic_api/generated/active_symbols_send.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/base_api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/services/dependency_injector/injector.dart';
import 'package:flutter_deriv_api/services/dependency_injector/module_container.dart';

class MarketSelector extends StatefulWidget {
  const MarketSelector({Key key}) : super(key: key);

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector> {
  @override
  void initState() {
    super.initState();
    _categorizeSymbols();
  }

  @override
  Widget build(BuildContext context) {
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
              ListTile(
                title: TextFormField(
                  onChanged: (String text) {},
                  cursorColor: Colors.white70,
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Asset',
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                onTap: () {},
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SymbolItem(),
                    SymbolItem(),
                    SymbolItem(),
                    SymbolItem(),
                    SymbolItem(),
                  ],
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

    final List<Market> markets = [];

    for (final symbol in activeSymbols) {
      if (!marketTitles.contains(symbol.market)) {
        marketTitles.add(symbol.market);
        markets.add(
          Market.fromSymbols(
            symbol.market,
            activeSymbols.where((e) => e.market == symbol.market).toList(),
          ),
        );
      }
    }
      print('');
  }
}
