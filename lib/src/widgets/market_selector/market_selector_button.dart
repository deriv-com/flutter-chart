import 'package:flutter/material.dart';

import 'models.dart';

/// A Button to open the market selector. The selected [Asset] should be passed as [asset]
class MarketSelectorButton extends StatelessWidget {
  const MarketSelectorButton({
    Key key,
    @required this.asset,
    this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  final Asset asset;

  static const iconFadeDuration = Duration(milliseconds: 100);

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
            fadeInDuration: iconFadeDuration,
            fadeOutDuration: iconFadeDuration,
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
