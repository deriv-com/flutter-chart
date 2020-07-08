import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';

class Market {
  Market({this.title});

  Market.fromSymbols(
    this.title,
    List<ActiveSymbol> symbols,
  ) {
    final List<String> subMarketTitles = [];
    for (final symbol in symbols) {
      if (!subMarketTitles.contains(symbol.submarket)) {
        subMarketTitles.add(symbol.submarket);
        subMarkets.add(
          SubMarket.fromSymbols(
            symbol.submarket,
            symbols
                .where((element) => element.submarket == symbol.submarket)
                .toList(),
          ),
        );
      }
    }
  }

  final String title;
  final List<SubMarket> subMarkets = [];
}

class SubMarket {
  SubMarket({this.title});

  SubMarket.fromSymbols(this.title, List<ActiveSymbol> symbols) {
    for (final symbol in symbols) {
      assets.add(Asset(symbol.symbol));
    }
  }

  final String title;
  final List<Asset> assets = [];
}

class Asset {
  Asset(this.title);

  final String title;
}
