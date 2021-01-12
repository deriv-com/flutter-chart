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
  }) : subMarkets = <SubMarket>[] {
    final HashSet<String> subMarketTitles = HashSet<String>();
    for (final Asset asset in assets) {
      if (!subMarketTitles.contains(asset.subMarket)) {
        subMarketTitles.add(asset.subMarket);
        subMarkets.add(
          SubMarket(
            name: asset.subMarket,
            displayName: asset.subMarketDisplayName,
            assets: assets
                .where((Asset element) => element.subMarket == asset.subMarket)
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
  }) : subMarkets = <SubMarket>[] {
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
              (SubMarket subMarket) => subMarket.containsAssetWithText(text),
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
              (Asset asset) => asset.displayName.toLowerCase().contains(text),
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
    this.isOpen = true,
    this.isFavourite = false,
  });

  /// Creates an [Asset] object from JSON map
  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        name: json['name'],
        displayName: json['display_name'],
        market: json['market'],
        marketDisplayName: json['market_display_name'],
        subMarket: json['sub_market'],
        subMarketDisplayName: json['sub_market_display_name'],
        isOpen: json['is_open'],
        isFavourite: json['is_favourite'],
      );

  final String name;
  final String displayName;
  final String market;
  final String marketDisplayName;
  final String subMarket;
  final String subMarketDisplayName;
  final bool isOpen;
  bool isFavourite;

  bool containsText(String text) =>
      displayName?.toLowerCase()?.contains(text) ?? false;

  void toggleFavourite() => isFavourite = !isFavourite;

  Asset copyWith({
    String name,
    String displayName,
    String market,
    String marketDisplayName,
    String subMarket,
    String subMarketDisplayName,
    bool isOpen,
    bool isFavourite,
  }) =>
      Asset(
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        market: market ?? this.market,
        marketDisplayName: marketDisplayName ?? this.marketDisplayName,
        subMarket: subMarket ?? this.subMarket,
        subMarketDisplayName: subMarketDisplayName ?? this.subMarketDisplayName,
        isOpen: isOpen ?? this.isOpen,
        isFavourite: isFavourite ?? this.isFavourite,
      );

  /// Converts this object to a JSON map
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'display_name': displayName,
        'market': market,
        'market_display_name': marketDisplayName,
        'sub_market': subMarket,
        'sub_market_display_name': subMarketDisplayName,
        'is_open': isOpen,
        'is_favourite': isFavourite,
      };
}
