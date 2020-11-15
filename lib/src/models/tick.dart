import 'package:meta/meta.dart';

@immutable
class Tick {
  Tick({
    @required this.epoch,
    @required this.quote,
  });

  final int epoch;
  final double quote;

  @override
  bool operator ==(covariant Tick other) =>
      epoch == other.epoch && quote == other.quote;

  @override
  int get hashCode => super.hashCode;
}
