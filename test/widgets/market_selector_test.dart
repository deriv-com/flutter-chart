import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Group 1', () {
    Asset r50;
    Asset r25Favorite;
    SubMarket r50SubMarket;
    SubMarket r25SubMarket;

    setUp(() {
      r50 = Asset(
          name: 'R_50', displayName: 'Volatility 50 Index', isFavorite: false);
      r25Favorite = Asset(
          name: 'R_25', displayName: 'Volatility 25 Index', isFavorite: true);
      r50SubMarket =
          SubMarket(name: 'smart', displayName: 'Smart', assets: <Asset>[r50]);
      r25SubMarket = SubMarket(
          name: 'smart2', displayName: 'Smart2', assets: <Asset>[r25Favorite]);
    });

    testWidgets('SelectedItem is ignored when it is not present in markets',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
          selectedItem: r25Favorite,
        ),
      ));
    });

    testWidgets('1 asset that is favorite', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r25SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Volatility 25 Index'), findsNWidgets(2));
    });

    testWidgets('1 asset that is NOT favorite', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(1));
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Volatility 50 Index'), findsNWidgets(1));
    });

    testWidgets('Favorite asset passed from outside', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
          favoriteAssets: [r50],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Volatility 50 Index'), findsNWidgets(2));
    });

    testWidgets('Favorite asset passed from outside NOT exist', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
          favoriteAssets: [r25Favorite],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Volatility 50 Index'), findsNWidgets(1));
    });

    testWidgets('Add to favorites by clicking favorite icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          onAssetClicked: (asset, isFavoriteClicked) {},
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(1));
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Volatility 50 Index'), findsNWidgets(1));

      await tester.pumpAndSettle();

      final favoriteIconFinder = find.byKey(ValueKey<String>('R_50-fav-icon'));
      await tester.tap(favoriteIconFinder);

      await tester.pump();

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Volatility 50 Index'), findsNWidgets(2));
    });

    testWidgets('No Favorites section when we remove the only favorite item',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          onAssetClicked: (asset, isFavoriteClicked) {},
          markets: [
            Market(subMarkets: [r25SubMarket])
          ],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));

      await tester.pumpAndSettle();

      final favoriteIconFinder = find.byKey(ValueKey<String>('R_25-fav-icon'));
      // There are two AssetItems for R_25, one in Favorites list and one in the assets list, We tap the first
      await tester.tap(favoriteIconFinder.first);
      await tester.pump();

      expect(find.byType(AssetItem), findsNWidgets(1));
      expect(find.text('Favorites'), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets(
        'Search bar TextField appears/disappear on switching to search mode on/off',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final textFieldKey = ValueKey<String>('search-bar-text-field');

      expect(find.byKey(textFieldKey), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(find.byKey(textFieldKey), findsNothing);
    });

    testWidgets('Clearing search bar TextField', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r25SubMarket])
          ],
        ),
      ));

      await tester.pumpAndSettle();

      final textFieldKey = ValueKey<String>('search-bar-text-field');

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
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r25SubMarket, r50SubMarket])
          ],
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(AssetItem), findsNWidgets(3));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final searchTextFieldFinder =
          find.byKey(ValueKey<String>('search-bar-text-field'));

      await tester.enterText(searchTextFieldFinder, '50');
      await tester.pump();

      expect(find.byType(AssetItem), findsOneWidget);
      expect(find.text('Smart'), findsOneWidget);

      await tester.enterText(searchTextFieldFinder, 'A non-relevant text');
      await tester.pump();

      expect(find.byType(AssetItem), findsNothing);
    });
  });
}
