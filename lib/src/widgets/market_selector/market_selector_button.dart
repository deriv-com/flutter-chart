import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'closed_tag.dart';
import 'models.dart';
import 'symbol_icon.dart';

/// A Button to open the market selector. The selected [Asset] should be passed as [asset].
class MarketSelectorButton extends StatelessWidget {
  /// Creates a Button to open the market selector. The selected [Asset] should be passed as [asset].
  const MarketSelectorButton({
    @required this.asset,
    Key key,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.theme,
  }) : super(key: key);

  /// Called when the market selector button is clicked.
  final VoidCallback onTap;

  /// The color of the button.
  final Color backgroundColor;

  /// The assigned radius of the button.
  ///
  /// Default is set to `BorderRadius.all(Radius.circular(4.0))`
  final BorderRadius borderRadius;

  /// The asset retrieved from the API.
  final Asset asset;

  /// The text style of the asset used inside the button.
  final TextStyle textStyle;

  /// The duration of the fade animaiton of the button icon.
  ///
  /// Default is set to `100` miliseconds.
  static const Duration iconFadeDuration = Duration(milliseconds: 100);

  /// Chart's theme.
  ///
  /// If not specified, [ChartDefaultDarkTheme] will be used.
  final ChartTheme theme;

  @override
  Widget build(BuildContext context) => Provider<ChartTheme>.value(
        value: theme ?? ChartDefaultDarkTheme(),
        child: FlatButton(
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
              const Spacer(),
              if (!asset.isOpen) ClosedTag(),
            ],
          ),
          onPressed: onTap,
        ),
      );
}
