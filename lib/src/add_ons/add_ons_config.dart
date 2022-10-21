import 'dart:convert';
import 'package:flutter/material.dart';

/// Add-ons config
@immutable
abstract class AddOnsConfig {
  /// Initializes
  const AddOnsConfig({
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
      other is AddOnsConfig &&
      jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}
