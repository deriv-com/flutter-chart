class Market {
  Market.fromAssets({
    this.name,
    this.displayName,
    List<Asset> assets,
  }) {
    final List<String> subMarketTitles = [];
    for (final asset in assets) {
      if (!subMarketTitles.contains(asset.subMarket)) {
        subMarketTitles.add(asset.subMarket);
        subMarkets.add(
          SubMarket(
            name: asset.subMarket,
            displayName: asset.subMarketDisplayName,
            assets: assets
                .where((element) => element.subMarket == asset.subMarket)
                .toList(),
          ),
        );
      }
    }
  }

  Market.fromSingleSubMarket({
    this.name,
    this.displayName,
    List<Asset> assets,
  }) {
    subMarkets.add(SubMarket(name: '', displayName: '', assets: assets));
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
  SubMarket({
    this.name,
    this.displayName,
    this.assets,
  });

  final String name;
  final String displayName;
  final List<Asset> assets;

  /// Returns true if any asset under this SubMarket contains the [filterText]
  bool containsAssetWithText(String filterText) =>
      assets.firstWhere(
          (asset) => asset.displayName.toLowerCase().contains(filterText),
          orElse: () => null) !=
      null;
}

/// A symbol item
class Asset {
  Asset({
    this.name,
    this.displayName,
    this.market,
    this.marketDisplayName,
    this.subMarket,
    this.subMarketDisplayName,
    this.isFavorite = false,
  });

  final String name;
  final String displayName;
  final String market;
  final String marketDisplayName;
  final String subMarket;
  final String subMarketDisplayName;
  bool isFavorite;

  void toggleFavorite() => isFavorite = !isFavorite;
}
