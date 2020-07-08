import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';

class Market {
  Market.fromSymbols({
    this.name,
    this.displayName,
    List<ActiveSymbol> symbols,
  }) {
    final List<String> subMarketTitles = [];
    for (final symbol in symbols) {
      if (!subMarketTitles.contains(symbol.submarket)) {
        subMarketTitles.add(symbol.submarket);
        subMarkets.add(
          SubMarket.fromSymbols(
            name: symbol.submarket,
            displayName: symbol.submarketDisplayName,
            symbols: symbols
                .where((element) => element.submarket == symbol.submarket)
                .toList(),
          ),
        );
      }
    }
  }

  final String name;
  final String displayName;
  final List<SubMarket> subMarkets = [];
}

class SubMarket {
  SubMarket.fromSymbols({
    this.name,
    this.displayName,
    List<ActiveSymbol> symbols,
  }) {
    for (final symbol in symbols) {
      assets.add(Asset(name: symbol.symbol, displayName: symbol.displayName));
    }
  }

  final String name;
  final String displayName;
  final List<Asset> assets = [];
}

class Asset {
  Asset({this.name, this.displayName});

  final String name;
  final String displayName;
}
