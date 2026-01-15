// ignore_for_file: avoid_redundant_argument_values

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/animated_highlight.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../helpers/image_mock_helper.dart';

void main() {
  group('Test different scenarios that might break the [MarketSelector] widget',
      () {
    late Asset r50;
    late Asset r25Favourite;
    late SubMarket r50SubMarket;
    late SubMarket r25SubMarket;

    setUpAll(() {
      setUpImageAssetMocking();
    });

    tearDownAll(() {
      tearDownImageAssetMocking();
    });

    setUp(() {
      r50 = Asset(
        name: 'R_50',
        displayName: 'Volatility 50 Index',
        market: 'synthetic',
        marketDisplayName: 'Synthetic Indices',
        subMarket: 'continues',
        subMarketDisplayName: 'Continues Indices',
        isOpen: true,
        isFavourite: false,
      );
      r25Favourite = Asset(
        name: 'R_25',
        displayName: 'Volatility 25 Index',
        isFavourite: true,
        isOpen: false,
      );
      r50SubMarket = SubMarket(
        name: 'smart',
        displayName: 'Smart',
        assets: <Asset?>[r50],
      );
      r25SubMarket = SubMarket(
        name: 'smart2',
        displayName: 'Smart2',
        assets: <Asset?>[r25Favourite],
      );
    });

    testWidgets('SelectedItem is ignored when it is not present in markets',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r50SubMarket])
          ],
          selectedItem: r25Favourite,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedHighlight), findsNothing);
    });

    testWidgets('Selected asset is highlighted', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r25SubMarket, r50SubMarket])
          ],
          selectedItem: r25Favourite,
        ),
      ));

      await tester.pumpAndSettle();

      // Must be two one the original and one in list of favorites
      expect(find.byType(AnimatedHighlight), findsNWidgets(2));
    });

    testWidgets('1 asset that is favourite', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r25SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favourites'), findsOneWidget);
      expect(find.text('Volatility 25 Index'), findsNWidgets(2));
    });

    testWidgets('1 asset that is NOT favourite', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r50SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(1));
      expect(find.text('Favourites'), findsNothing);
      expect(find.text('Volatility 50 Index'), findsNWidgets(1));
    });

    testWidgets('Favourite asset passed from outside',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r50SubMarket])
          ],
          favouriteAssets: <Asset>[r50],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favourites'), findsOneWidget);
      expect(find.text('Volatility 50 Index'), findsNWidgets(2));
    });

    testWidgets('Favourite asset passed from outside NOT exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r50SubMarket])
          ],
          favouriteAssets: <Asset>[r25Favourite],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favourites'), findsOneWidget);
      expect(find.text('Volatility 50 Index'), findsNWidgets(1));
    });

    testWidgets('Add to favourites by clicking star icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r50SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(1));
      expect(find.text('Favourites'), findsNothing);
      expect(find.text('Volatility 50 Index'), findsNWidgets(1));

      await tester.pumpAndSettle();

      final Finder favouriteIconFinder =
          find.byKey(const ValueKey<String>('R_50-fav-icon'));
      await tester.tap(favouriteIconFinder);

      await tester.pump();

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favourites'), findsOneWidget);
      expect(find.text('Volatility 50 Index'), findsNWidgets(2));
    });

    testWidgets('No Favourites section when we remove the only favourite item',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r25SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));

      await tester.pumpAndSettle();

      final Finder favouriteIconFinder =
          find.byKey(const ValueKey<String>('R_25-fav-icon'));
      // There are two AssetItems for R_25, one in Favourites list and one
      // in the assets list, We tap the first
      await tester.tap(favouriteIconFinder.first);
      await tester.pump();

      expect(find.byType(AssetItem), findsNWidgets(1));
      expect(find.text('Favourites'), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets(
        'Search bar TextField appears/disappear on switching to search mode on/off',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ChartLocalization.delegate,
        ],
        supportedLocales: ChartLocalization.delegate.supportedLocales,
        home: const MarketSelector(
          markets: <Market>[],
        ),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      const ValueKey<String> textFieldKey =
          ValueKey<String>('search-bar-text-field');

      expect(find.byKey(textFieldKey), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(find.byKey(textFieldKey), findsNothing);
    });

    testWidgets('Clearing search bar TextField', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ChartLocalization.delegate,
        ],
        supportedLocales: ChartLocalization.delegate.supportedLocales,
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r25SubMarket])
          ],
        ),
      ));

      await tester.pumpAndSettle();

      const ValueKey<String> textFieldKey =
          ValueKey<String>('search-bar-text-field');

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byKey(textFieldKey), 'Some text');
      await tester.pump();

      expect(find.text('Some text'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Some text'), findsNothing);
    });

    testWidgets('Filtering assets shows the assets containing filter text',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ChartLocalization.delegate,
        ],
        supportedLocales: ChartLocalization.delegate.supportedLocales,
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r25SubMarket, r50SubMarket])
          ],
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(AssetItem), findsNWidgets(3));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final Finder searchTextFieldFinder =
          find.byKey(const ValueKey<String>('search-bar-text-field'));

      await tester.enterText(searchTextFieldFinder, '50');
      await tester.pump();

      expect(find.byType(AssetItem), findsOneWidget);
      expect(find.text('Smart'), findsOneWidget);

      await tester.enterText(searchTextFieldFinder, 'A non-relevant text');
      await tester.pump();

      expect(find.byType(AssetItem), findsNothing);
      expect(
        find.text('No results for \"A non-relevant text\"'),
        findsOneWidget,
      );
    });

    testWidgets('Shows closed tag on closed assets',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: <Market>[
            Market(subMarkets: <SubMarket>[r25SubMarket, r50SubMarket])
          ],
        ),
      ));

      await tester.pumpAndSettle();

      // Should be two, r25 original and in favourites list
      expect(find.text('CLOSED'), findsNWidgets(2));
      expect(find.text('Volatility 25 Index'), findsNWidgets(2));
    });

    test('Asset class toJson <-> fromJson conversion', () {
      final Map<String, dynamic> r50JSON = r50.toJson();

      final Asset r50Copy = Asset.fromJson(r50JSON);

      expect(r50.name, r50Copy.name);
      expect(r50.displayName, r50Copy.displayName);
      expect(r50.market, r50Copy.market);
      expect(r50.marketDisplayName, r50Copy.marketDisplayName);
      expect(r50.subMarket, r50Copy.subMarket);
      expect(r50.subMarketDisplayName, r50Copy.subMarketDisplayName);
      expect(r50.isOpen, r50Copy.isOpen);
      expect(r50.isFavourite, r50Copy.isFavourite);
    });
  });
}
