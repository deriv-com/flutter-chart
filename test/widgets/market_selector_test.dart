import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Group 1', () {
    final r50 = Asset(
      name: 'R_50',
      displayName: 'Volatility 50 Index',
      isFavorite: false,
    );

    final r25 = Asset(
      name: 'R_25',
      displayName: 'Volatility 25 Index',
      isFavorite: true,
    );

    final r50SubMarket = SubMarket(
      name: 'smart',
      displayName: 'Smart',
      assets: <Asset>[r50],
    );

    final r25SubMarket = SubMarket(
      name: 'smart2',
      displayName: 'Smart2',
      assets: <Asset>[r25],
    );

    testWidgets('Selected asset not exist among assets works OK',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
          selectedItem: r25,
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
    });

    testWidgets('Favorite asset passed from outside NOT exist', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MarketSelector(
          markets: [
            Market(subMarkets: [r50SubMarket])
          ],
          favoriteAssets: [r25],
        ),
      ));

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('Add to favorites works OK', (tester) async {
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

      await tester.pumpAndSettle();

      final favoriteIconFinder = find.byKey(ValueKey<String>('R_50-fav-icon'));
      await tester.tap(favoriteIconFinder);

      await tester.pump();

      expect(find.byType(AssetItem), findsNWidgets(2));
      expect(find.text('Favorites'), findsOneWidget);
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
    });
  });
}
