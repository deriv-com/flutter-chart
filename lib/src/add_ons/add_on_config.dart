import 'package:equatable/equatable.dart';

/// Config for add-ons such as indicators and drawing tools
abstract class AddOnConfig with EquatableMixin {
  /// Initializes [AddOnConfig].
  const AddOnConfig({
    this.isOverlay = true,
    this.number = 0,
    this.configId,
  });

  /// Drawing tool config id.
  final String? configId;

  /// Whether the add-on is an overlay on the main chart or displays on a
  /// separate chart. Default is set to `true`.
  final bool isOverlay;

  /// Serialization to JSON. Serves as value in key-value storage.
  ///
  /// Must specify add-on `name` with `nameKey`.
  Map<String, dynamic> toJson();

  /// The number of this add-on.
  ///
  /// The default value is 0, that means this instance is the first add-on of
  /// this type added by the user. in case the user adds more than one add-on
  /// of the same type, the number will be incremented by 1 for each new add-on.
  final int number;

  @override
  List<Object> get props => <Object>[toJson()];
}
