import 'package:equatable/equatable.dart';

/// Config for add-ons such as indicators and drawing tools
abstract class AddOnConfig with EquatableMixin {
  /// Initializes [AddOnConfig].
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
  List<Object> get props => <Object>[toJson()];
}
