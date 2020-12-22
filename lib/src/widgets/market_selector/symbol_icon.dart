import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset_icon_placeholder.dart';

/// Provides the path to the PNG file located in Chart package directory.
String getSymbolAssetPath(String assetCode) =>
    'assets/icons/symbols/$assetCode.png';

/// A wrapper widget around [AssetImage] which provides image icon for the
/// given [symbolCode].
class SymbolIcon extends FadeInImage {
  /// Initializes
  SymbolIcon({
    @required String symbolCode,
    double width = 32,
    double height = 32,
    Duration fadeDuration = const Duration(milliseconds: 50),
  }) : super(
          width: width,
          height: height,
          placeholder: const AssetImage(
            'assets/icons/icon_placeholder.png',
            package: 'deriv_chart',
          ),
          image: AssetImage(
            getSymbolAssetPath(symbolCode),
            package: 'deriv_chart',
          ),
          fadeInDuration: fadeDuration,
          fadeOutDuration: fadeDuration,
        );
}
