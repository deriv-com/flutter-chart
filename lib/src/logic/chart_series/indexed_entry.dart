/// A model class to hold an Entry of type [T] and its index in the whole list of
/// entries.

// @dart=2.9

class IndexedEntry<T> {
  /// Initializes
  const IndexedEntry(this.entry, this.index);

  /// The entry.
  final T entry;

  /// Index of the [entry].
  final int index;
}
