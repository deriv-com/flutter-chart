import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Provides the path to the SVG file located in Chart package directory.
@Deprecated('next release')
String getSVGPathForAsset(String assetCode) =>
    'assets/icons/symbols/$assetCode.svg';

/// Just a wrapper widget around [SvgPicture.asset()] for `MarketSelector` symbols,
/// to be usable on the Apps using this chart package.
@Deprecated('next release')
class SymbolSvgPicture extends StatelessWidget {
  /// Initializes a wrapper widget around [SvgPicture.asset()] for [MarketSelector] symbols,
  /// to be usable on the Apps using this chart package.
  const SymbolSvgPicture({
    @required this.symbolCode,
    Key key,
    this.bundle,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholderBuilder,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.hardEdge,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
  }) : super(key: key);

  /// Symbol code.
  final String symbolCode;

  /// AssetBundle.
  final AssetBundle bundle;

  /// Width.
  final double width;

  /// Height.
  final double height;

  /// The default is [BoxFit.contain].
  final BoxFit fit;

  /// alignment
  /// Default is [Alignment.center]
  final AlignmentGeometry alignment;

  /// The placeholder to use while fetching, decoding, and parsing the SVG data.
  final WidgetBuilder placeholderBuilder;

  /// If true, will horizontally flip the picture in [TextDirection.rtl] contexts.
  final bool matchTextDirection;

  /// If true, will allow the SVG to be drawn outside of the clip boundary of its
  /// viewBox.
  final bool allowDrawingOutsideViewBox;

  /// The `Semantics.label` for this picture.
  final String semanticsLabel;

  /// Whether to exclude this picture from semantics.
  final bool excludeFromSemantics;

  /// clipBehavior
  /// Defaults to [Clip.hardEdge], and must not be null.
  final Clip clipBehavior;

  /// Color.
  final Color color;

  /// colorBlendMode.
  /// Default is [BlendMode.srcIn]
  final BlendMode colorBlendMode;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        getSVGPathForAsset(symbolCode),
        matchTextDirection: matchTextDirection,
        bundle: bundle,
        package: 'deriv_chart',
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
        placeholderBuilder: placeholderBuilder,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticsLabel: semanticsLabel,
        excludeFromSemantics: excludeFromSemantics,
        clipBehavior: clipBehavior,
      );
}
