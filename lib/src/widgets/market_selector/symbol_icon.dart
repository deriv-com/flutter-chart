import 'package:flutter/material.dart';

/// Provides the path to the PNG file located in Chart package directory.
String getSymbolAssetPath(String assetCode) =>
    'assets/icons/symbols/${assetCode.toLowerCase()}.png';

const String _placeHolderPath = 'assets/icons/icon_placeholder.png';
const String _packageName = 'deriv_chart';

/// A wrapper widget around [AssetImage] which provides image icon for the
/// given `symbolCode`.
class SymbolIcon extends FadeInImage {
  /// Initializes a wrapper widget around [AssetImage] which provides image icon for the
  /// given [symbolCode].
  SymbolIcon({
    required String symbolCode,
    double width = 32,
    double height = 32,
    Duration fadeDuration = const Duration(milliseconds: 50),
  }) : super(
          width: width,
          height: height,
          placeholder: const AssetImage(
            _placeHolderPath,
            package: _packageName,
          ),
          image: AssetImage(
            getSymbolAssetPath(symbolCode),
            package: _packageName,
          ),
          imageErrorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) =>
              // TODO(NA): Replace with a placeholder which somehow indicates loading icon has failed
              Image.asset(
            _placeHolderPath,
            package: _packageName,
            width: width,
            height: height,
          ),
          fadeInDuration: fadeDuration,
          fadeOutDuration: fadeDuration,
        );
}
