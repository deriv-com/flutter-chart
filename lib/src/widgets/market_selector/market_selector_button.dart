import 'package:flutter/material.dart';

import 'models.dart';
import 'symbol_icon.dart';

/// A Button to open the market selector. The selected [Asset] should be passed as [asset]
class MarketSelectorButton extends StatelessWidget {
  ///Creates a Button to open the market selector. The selected [Asset] should be passed as [asset]
  const MarketSelectorButton({
    Key key,
    @required this.asset,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.white),
  }) : super(key: key);

  /// Called when the market selector button is clicked.
  final VoidCallback onTap;

  /// The color of the button.
  final Color backgroundColor;

  /// The assigned radius of the button.
  ///
  /// Default is set to `BorderRadius.all(Radius.circular(4.0))`
  final BorderRadius borderRadius;

  /// The asset retrieved from the API
  final Asset asset;

  /// The text style of the asset used inside the button.
  final TextStyle textStyle;

  /// The duration of the fade animaiton of the button icon.
  ///
  /// Default is set to `100` miliseconds
  static const iconFadeDuration = const Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: const EdgeInsets.all(8),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
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
}
