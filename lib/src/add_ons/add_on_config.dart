import 'dart:convert';
import 'package:flutter/material.dart';

/// Config for add-ons such as indicators and drawing tools
@immutable
abstract class AddOnConfig {
  /// Initializes
  const AddOnConfig({
    this.isOverlay = true,
  });

  /// Whether the add-on is an overlay on the main chart or displays on a
  /// separate chart. Default is set to `true`.
  final bool isOverlay;

  /// Serialization to JSON. Serves as value in key-value storage.
  ///
  /// Must specify add-on `name` with `nameKey`.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(dynamic other) =>
      other is AddOnConfig &&
      jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}
