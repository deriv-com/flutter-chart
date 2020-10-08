import 'package:flutter/material.dart';

import 'asset_icon_placeholder.dart';
import 'models.dart';
import 'symbol_svg_picture.dart';

/// A Button to open the market selector. The selected [Asset] should be passed as [asset]
class MarketSelectorButton extends StatelessWidget {
  const MarketSelectorButton({
    Key key,
    @required this.asset,
    this.onTap,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.white),
  }) : super(key: key);

  final VoidCallback onTap;

  final Asset asset;

  final TextStyle textStyle;

  static const iconFadeDuration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SymbolSvgPicture(
            symbolCode: asset.name,
            width: 32,
            height: 32,
            placeholderBuilder: (BuildContext context) =>
                AssetIconPlaceholder(),
          ),
          SizedBox(width: 16),
          Text(asset.displayName, style: textStyle),
        ],
      ),
      onPressed: onTap,
    );
  }
}
