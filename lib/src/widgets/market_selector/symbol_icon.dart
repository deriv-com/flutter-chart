import 'package:flutter/material.dart';

/// Provides the path to the PNG file located in the consumer app's assets.
///
/// By default, this generates paths in the format:
/// `assets/icons/symbols/{assetCode}.png`
///
/// Consumers can override this by providing a custom [assetPathBuilder] to
/// [SymbolIcon].
String getSymbolAssetPath(String assetCode) =>
    'assets/icons/symbols/${assetCode.toLowerCase()}.png';

/// Default path to the placeholder icon.
///
/// Consumers should provide this asset in their app's assets folder or
/// override it using the [placeholderPath] parameter in [SymbolIcon].
const String kDefaultPlaceholderPath = 'assets/icons/icon_placeholder.png';

/// A wrapper widget around [AssetImage] which provides image icon for the
/// given `symbolCode`.
///
/// This widget expects assets to be provided by the consuming application.
/// By default, it looks for assets in the consuming app's assets folder
/// (not in the deriv_chart package).
///
/// ## Asset Structure
///
/// The widget expects the following asset structure in the consuming app:
/// ```
/// assets/
///   icons/
///     icon_placeholder.png
///     symbols/
///       {symbol_code}.png
/// ```
///
/// ## Customization
///
/// You can customize the asset paths by providing:
/// - [assetPathBuilder]: Custom function to build symbol asset paths
/// - [placeholderPath]: Custom path to the placeholder image
/// - [package]: Specify a package name if assets are in a different package
///
/// ## Example Usage
///
/// ```dart
/// // Using default paths (assets in consuming app)
/// SymbolIcon(symbolCode: 'frxeurusd')
///
/// // Using custom paths
/// SymbolIcon(
///   symbolCode: 'frxeurusd',
///   assetPathBuilder: (code) => 'custom/path/$code.png',
///   placeholderPath: 'custom/placeholder.png',
/// )
///
/// // Using assets from a different package
/// SymbolIcon(
///   symbolCode: 'frxeurusd',
///   package: 'my_assets_package',
/// )
/// ```
class SymbolIcon extends FadeInImage {
  /// Initializes a wrapper widget around [AssetImage] which provides image
  /// icon for the given [symbolCode].
  ///
  /// Assets are expected to be in the consuming application by default.
  ///
  /// Parameters:
  /// - [symbolCode]: The code of the symbol to display (e.g., 'frxeurusd')
  /// - [width]: Width of the icon (default: 32)
  /// - [height]: Height of the icon (default: 32)
  /// - [fadeDuration]: Duration of fade animation (default: 50ms)
  /// - [assetPathBuilder]: Custom function to build asset paths. If null,
  ///   uses [getSymbolAssetPath]
  /// - [placeholderPath]: Path to placeholder image. If null, uses
  ///   [kDefaultPlaceholderPath]
  /// - [package]: Package name where assets are located. If null, assets are
  ///   expected in the consuming app's assets folder
  SymbolIcon({
    required String symbolCode,
    double width = 32,
    double height = 32,
    Duration fadeDuration = const Duration(milliseconds: 50),
    String Function(String)? assetPathBuilder,
    String? placeholderPath,
    String? package,
  }) : super(
          width: width,
          height: height,
          placeholder: AssetImage(
            placeholderPath ?? kDefaultPlaceholderPath,
            package: package,
          ),
          image: AssetImage(
            assetPathBuilder?.call(symbolCode) ??
                getSymbolAssetPath(symbolCode),
            package: package,
          ),
          imageErrorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) =>
              // TODO(NA): Replace with a placeholder which somehow indicates
              //  loading icon has failed
              Image.asset(
            placeholderPath ?? kDefaultPlaceholderPath,
            package: package,
            width: width,
            height: height,
          ),
          fadeInDuration: fadeDuration,
          fadeOutDuration: fadeDuration,
        );
}
