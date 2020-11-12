import 'package:meta/meta.dart';

extension StringExtension on String {
  String replaceLast({
    @required String toReplace,
    @required String replacement,
  }) {
    int position = this.lastIndexOf(toReplace);
    if (position > -1) {
      return this.substring(0, position) +
          replacement +
          this.substring(position + toReplace.length);
    } else {
      return this;
    }
  }
}
