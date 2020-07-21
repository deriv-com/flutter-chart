import 'package:flutter/material.dart';

import 'models.dart';

class MarketSelectorButton extends StatelessWidget {
  const MarketSelectorButton({
    Key key,
    this.onTap,
    this.asset,
  }) : super(key: key);

  final VoidCallback onTap;

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FadeInImage(
            width: 32,
            height: 32,
            placeholder: AssetImage(
              'assets/icons/icon_placeholder.png',
              package: 'deriv_chart',
            ),
            image: AssetImage(
              'assets/icons/${asset.name}.png',
              package: 'deriv_chart',
            ),
            fadeInDuration: const Duration(milliseconds: 100),
            fadeOutDuration: const Duration(milliseconds: 100),
          ),
          SizedBox(width: 16),
          Text(
            asset.displayName,
            style: TextStyle(
              fontSize: 14, // TODO(Ramin): Use Chart's theme when its ready
              color: Colors.white,
            ),
          ),
        ],
      ),
      onPressed: onTap,
    );
  }
}
