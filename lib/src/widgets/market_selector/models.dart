/// Symbol item representing a symbol has gotten from the API.
class Symbol {
  Symbol({
    this.market,
    this.submarket,
    this.symbol,
    this.displayName,
    this.submarketDisplayName,
  });

  final String market;
  final String submarket;
  final String symbol;
  final String displayName;
  final String submarketDisplayName;
}

class Market {
  Market.fromSymbols({
    this.name,
    this.displayName,
    List<Symbol> symbols,
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

  /// Returns true if any asset under this market contains the [filterText]
  bool containsAssetWithText(String filterText) =>
      subMarkets.firstWhere(
          (subMarket) => subMarket.containsAssetWithText(filterText),
          orElse: () => null) !=
      null;
}

class SubMarket {
  SubMarket.fromSymbols({
    this.name,
    this.displayName,
    List<Symbol> symbols,
  }) {
    for (final symbol in symbols) {
      assets.add(Asset(name: symbol.symbol, displayName: symbol.displayName));
    }
  }

  final String name;
  final String displayName;
  final List<Asset> assets = [];

  /// Returns true if any asset under this SubMarket contains the [filterText]
  bool containsAssetWithText(String filterText) =>
      assets.firstWhere(
          (asset) => asset.displayName.toLowerCase().contains(filterText),
          orElse: () => null) !=
      null;
}

/// A symbol item
class Asset {
  Asset({this.name, this.displayName, this.isFavorite = false});

  final String name;
  final String displayName;
  final bool isFavorite;
}
