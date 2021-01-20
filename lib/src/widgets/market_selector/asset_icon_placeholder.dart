import 'package:flutter/material.dart';

/// A place holder to show until SVG icons load.
class AssetIconPlaceholder extends StatelessWidget {
  /// Initializes a place holder to show until SVG icons load.
  const AssetIconPlaceholder({
    Key key,
    this.size = const Size(24, 16),
    this.color = Colors.grey,
  }) : super(key: key);

  /// Color.
  final Color color;

  /// The size of the placeholder.
  final Size size;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        width: size.width,
        height: size.height,
      );
}
