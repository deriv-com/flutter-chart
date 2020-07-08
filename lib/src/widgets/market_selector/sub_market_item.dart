import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:deriv_chart/src/widgets/market_selector/asset_item.dart';
import 'package:flutter/material.dart';

class SubMarketItem extends StatelessWidget {
  const SubMarketItem({Key key, this.subMarket}) : super(key: key);

  final SubMarket subMarket;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF151717),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 16, left: 8),
              child: Text(
                subMarket.displayName,
                style: TextStyle(fontSize: 14, color: const Color(0xFF6E6E6E)),
              ),
            ),
            ...subMarket.assets.map((e) => AssetItem(asset: e)).toList()
          ],
        ),
      );
}
