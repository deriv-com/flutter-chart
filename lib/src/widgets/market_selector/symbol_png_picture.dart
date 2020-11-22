import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset_icon_placeholder.dart';

/// Provides the path to the PNG file located in Chart package directory.
String getPNGPathForAsset(String assetCode) =>
    'assets/icons/symbols/$assetCode.png';

///A wrapper widget around [AssetImage] which provides image icon for the
///given [symbolCode].
class SymbolPNGPicture extends StatelessWidget {
  /// Initializes
  const SymbolPNGPicture({
    Key key,
    @required this.symbolCode,
    this.width,
    this.height,
  }) : super(key: key);

  /// Symbol code
  final String symbolCode;

  /// Width
  final double width;

  /// Height
  final double height;

  /// Duration of fade In
  static const Duration iconFadeInDuration = Duration(milliseconds: 50);

  @override
  Widget build(BuildContext context) =>
      FadeInImage(
        width: width,
        height: height,
        placeholder: const AssetImage(
          'assets/icons/icon_placeholder.png',
          package: 'deriv_chart',
        ),
        image: AssetImage(
          getPNGPathForAsset(symbolCode),
          package: 'deriv_chart',
        ),
        fadeInDuration: iconFadeInDuration,
        fadeOutDuration: iconFadeInDuration,
      );
}
