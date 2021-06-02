import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oscillator_lines_config.g.dart';

/// Oscillator Limits.
@JsonSerializable()
class OscillatorLinesConfig {
  /// Initializes
  const OscillatorLinesConfig({
    this.overBoughtPrice,
    this.overSoldPrice,
    this.lineStyle,
  });

  /// The price to show the over bought line.
  final double overBoughtPrice;

  /// The price to show the over sold line.
  final double overSoldPrice;

  /// The WilliamsR horizontal lines style(overBought and overSold).
  final LineStyle lineStyle;

  /// Initializes from JSON.
  factory OscillatorLinesConfig.fromJson(Map<String, dynamic> json) =>
      _$OscillatorLinesConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'WilliamsR';

  @override
  Map<String, dynamic> toJson() => _$OscillatorLinesConfigToJson(this);
}
