import 'package:flutter/material.dart';

import 'models.dart';
import 'symbol_icon.dart';

/// A Button to open the market selector. The selected [Asset] should be passed as [asset]
class MarketSelectorButton extends StatelessWidget {
  const MarketSelectorButton({
    @required this.asset,
    Key key,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.white),
  }) : super(key: key);

  final VoidCallback onTap;

  final Color backgroundColor;

  final BorderRadius borderRadius;

  final Asset asset;

  final TextStyle textStyle;

  static const Duration iconFadeDuration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) => FlatButton(
        padding: const EdgeInsets.all(8),
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          children: <Widget>[
            SymbolIcon(
              symbolCode: asset.name,
            ),
            const SizedBox(width: 8),
            Text(asset.displayName, style: textStyle),
          ],
        ),
        onPressed: onTap,
      );
}
