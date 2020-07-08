import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/sub_market_item.dart';
import 'package:flutter/material.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({Key key, this.market}) : super(key: key);

  final Market market;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF0E0E0E),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 24, left: 8, bottom: 8),
              child: Text(
                market.displayName,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            ...market.subMarkets
                .map((e) => SubMarketItem(
                      subMarket: e,
                    ))
                .toList(),
          ],
        ),
      );
}
