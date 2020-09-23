import 'package:flutter/material.dart';

/// A place holder to show until SVG icons load.
class AssetIconPlaceholder extends StatelessWidget {
  /// Initializes
  const AssetIconPlaceholder({
    Key key,
    this.size = const Size(24, 16),
  }) : super(key: key);

  /// The size of the placeholder
  final Size size;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        width: size.width,
        height: size.height,
      );
}
