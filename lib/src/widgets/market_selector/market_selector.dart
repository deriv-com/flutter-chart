import 'package:deriv_chart/src/widgets/market_selector/symbol_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';

class MarketSelector extends StatefulWidget {
  const MarketSelector({Key key, this.activeSymbols}) : super(key: key);

  final List<ActiveSymbol> activeSymbols;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector> {
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
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Assets',
                  textAlign: TextAlign.center,
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
}
