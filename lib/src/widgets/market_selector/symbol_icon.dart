import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset_icon_placeholder.dart';

/// Provides the path to the PNG file located in Chart package directory.
String getSymbolAssetPath(String assetCode) =>
    'assets/icons/symbols/$assetCode.png';

/// A wrapper widget around [AssetImage] which provides image icon for the
/// given [symbolCode].
class SymbolIcon extends FadeInImage {
  /// Symbol code
  final String symbolCode;

  /// Width
  final double width;

  /// Height
  final double height;

  /// Duration of fade In
  final Duration fadeDuration;

  /// Initializes
  SymbolIcon({
    @required this.symbolCode,
    this.width = 32,
    this.height = 32,
    this.fadeDuration = const Duration(milliseconds: 50),
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
