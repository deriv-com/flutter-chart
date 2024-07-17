import 'package:equatable/equatable.dart';

/// Config wrapper for add-ons such as indicators and drawing tools.
/// It adds id to the add-on config so it an be used to identify the add-ons.
class AddOnConfigWrapper<T> with EquatableMixin {
  /// Initializes [AddOnConfigWrapper].
  AddOnConfigWrapper(this.addOnConfig, this.id);

  /// Add-on config.
  final T addOnConfig;

  /// Add-on config id.
  final String id;

  /// Creates a copy of this object with the given fields replaced by the new
  /// values.
  AddOnConfigWrapper<T> copyWith({
    T? addOnConfig,
    String? id,
  }) =>
      AddOnConfigWrapper<T>(
        addOnConfig ?? this.addOnConfig,
        id ?? this.id,
      );

  @override
  List<Object?> get props => <Object?>[addOnConfig, id];
}

/// Generates a random id for the add-on config.
String generateRandomId() => DateTime.now().microsecondsSinceEpoch.toString();
