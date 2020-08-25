import 'dart:collection';

/// A class to keep a market's information.
class Market {
  Market({
    this.name,
    this.displayName,
    this.subMarkets,
  });

  Market.fromAssets({
    this.name,
    this.displayName,
    List<Asset> assets,
  }) : subMarkets = List<SubMarket>() {
    final HashSet<String> subMarketTitles = HashSet<String>();
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

  Market.fromSubMarketAssets({
    this.name,
    this.displayName,
    List<Asset> assets,
  }) : subMarkets = List<SubMarket>() {
    subMarkets.add(SubMarket(
      name: name,
      displayName: displayName,
      assets: assets,
    ));
  }

  final String name;
  final String displayName;
  final List<SubMarket> subMarkets;

  bool containsText(String text) =>
      displayName?.toLowerCase()?.contains(text) ?? false;

  /// Returns true if any asset under this market contains the [text]
  bool containsAssetWithText(String text) =>
      containsText(text) ||
      subMarkets.firstWhere(
              (subMarket) => subMarket.containsAssetWithText(text),
              orElse: () => null) !=
          null;
}

/// A class to keep a sub-market's information
class SubMarket {
  SubMarket({
    this.name,
    this.displayName,
    this.assets,
  });

  final String name;
  final String displayName;
  final List<Asset> assets;

  bool containsText(String text) =>
      displayName?.toLowerCase()?.contains(text) ?? false;

  /// Returns true if any asset under this sub-market contains the [text]
  bool containsAssetWithText(String text) =>
      containsText(text) ||
      assets.firstWhere(
              (asset) => asset.displayName.toLowerCase().contains(text),
              orElse: () => null) !=
          null;
}

/// Representing an active symbol retrieved from the API
class Asset {
  Asset({
    this.name,
    this.displayName,
    this.market,
    this.marketDisplayName,
    this.subMarket,
    this.subMarketDisplayName,
    this.isFavourite = false,
  });

  final String name;
  final String displayName;
  final String market;
  final String marketDisplayName;
  final String subMarket;
  final String subMarketDisplayName;
  bool isFavourite;

  bool containsText(String text) =>
      displayName?.toLowerCase()?.contains(text) ?? false;

  void toggleFavourite() => isFavourite = !isFavourite;
}
