import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oscillator_lines_config.g.dart';

/// Oscillator Limits.
@JsonSerializable()
class OscillatorLinesConfig {
  /// Initializes
  const OscillatorLinesConfig({
    required this.overboughtValue,
    required this.oversoldValue,
    this.overboughtStyle = const LineStyle(thickness: 0.5),
    this.oversoldStyle = const LineStyle(thickness: 0.5),
    this.id,
  });

  /// Initializes from JSON.
  factory OscillatorLinesConfig.fromJson(Map<String, dynamic> json) =>
      _$OscillatorLinesConfigFromJson(json);

  /// The ID of this [OscillatorLinesConfig].
  final String? id;

  /// The price to show the over bought line.
  final double overboughtValue;

  /// The price to show the over sold line.
  final double oversoldValue;

  /// The overbought line style.
  final LineStyle overboughtStyle;

  /// The oversold line style.
  final LineStyle oversoldStyle;

  /// Parses this instance of [OscillatorLinesConfig] into a Map<String,dynamic>
  Map<String, dynamic> toJson() => _$OscillatorLinesConfigToJson(this);
}
