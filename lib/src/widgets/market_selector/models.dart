import 'dart:collection';
import 'package:collection/collection.dart' show IterableExtension;

/// A class to keep a market's information.
class Market {
  /// Creates a class to keep a market's information.
  Market({
    required this.subMarkets,
    this.name = '',
    String? displayName,
  }) : displayName = displayName ?? name;

  /// Creates a market from a given `list` of assets.
  Market.fromAssets({
    required this.name,
    required this.displayName,
    required List<Asset> assets,
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

  /// Creates one market with one submarket from the given assets.
  Market.fromSubMarketAssets({
    required this.name,
    required this.displayName,
    required List<Asset?> assets,
  }) : subMarkets = <SubMarket>[] {
    subMarkets.add(SubMarket(
      name: name,
      displayName: displayName,
      assets: assets,
    ));
  }

  /// The name of the market.
  final String name;

  /// The displaying name of the market.
  final String displayName;

  /// The list of submarkets that go under this market.
  final List<SubMarket?> subMarkets;

  /// Checks if the [displayName] contains the given `text`
  bool containsText(String text) => displayName.toLowerCase().contains(text);

  /// Returns true if any asset under this market contains the [text].
  bool containsAssetWithText(String text) =>
      containsText(text) ||
      subMarkets.firstWhereOrNull((SubMarket? subMarket) =>
              subMarket!.containsAssetWithText(text)) !=
          null;
}

/// A class to keep a sub-market's information.
class SubMarket {
  /// Creates a class to keep a sub-market's information.
  SubMarket({
    required this.name,
    required this.assets,
    String? displayName,
  }) : displayName = displayName ?? name;

  /// The name of the sub-market.
  final String name;

  /// The displaying Name of the sub-market.
  final String displayName;

  /// The list of assets given from api with the information of each sub-market.
  final List<Asset?> assets;

  /// Checks if the [displayName] contains the given `text`.
  bool containsText(String text) => displayName.toLowerCase().contains(text);

  /// Returns true if any asset under this sub-market contains the [text].
  bool containsAssetWithText(String text) =>
      containsText(text) ||
      assets.firstWhereOrNull((Asset? asset) =>
              asset!.displayName.toLowerCase().contains(text)) !=
          null;
}

/// Representing an active symbol retrieved from the API.
class Asset {
  /// Initializes a class representing an active symbol retrieved from the API.
  Asset({
    required this.name,
    this.market = '',
    this.subMarket = '',
    String? displayName,
    String? marketDisplayName,
    String? subMarketDisplayName,
    this.isOpen = true,
    this.isFavourite = false,
  })  : displayName = displayName ?? name,
        marketDisplayName = marketDisplayName ?? market,
        subMarketDisplayName = subMarketDisplayName ?? subMarket;

  /// Creates an [Asset] object from JSON map.
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

  /// The name of the active symbol.
  final String name;

  /// The displaying name of the active symbol.
  final String displayName;

  /// The name of the active symbol's market.
  final String market;

  /// The displaying name of the active symbol's market.
  final String marketDisplayName;

  /// The name of the active symbol's sub-market.
  final String subMarket;

  /// The displaying name of the active symbol's sub-market.
  final String subMarketDisplayName;

  /// Whether the market is currently open or not.
  final bool isOpen;

  /// Whether the market is favorited by the user or not.
  bool isFavourite;

  /// Checks if the [displayName] contains the given `text`.

  bool containsText(String text) => displayName.toLowerCase().contains(text);

  /// Toggles the is [isFavourite] property of the class.
  void toggleFavourite() => isFavourite = !isFavourite;

  /// Copies the class with changes to given attributes.
  Asset copyWith({
    String? name,
    String? displayName,
    String? market,
    String? marketDisplayName,
    String? subMarket,
    String? subMarketDisplayName,
    bool? isOpen,
    bool? isFavourite,
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

  /// Converts this object to a JSON map.
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
