import 'indicator_options.dart';

/// Ichimoku Clouds Options.
class IchimokuCloudOptions extends IndicatorOptions {
  ///Initializes an Ichimoku Clouds Options.
  const IchimokuCloudOptions({
    this.conversionLinePeriod = 9,
    this.baseLinePeriod = 26,
    this.leadingSpanBPeriod = 52,
  });

  /// The `period` for the `IchimokuConversionLine`. Default is set to `9`.
  final int conversionLinePeriod;

  /// The `period` for the `IchimokuBaseLine` and the `offset` of `leadingSpanA`
  /// and `leadingSpanB`. Default is set to `26`.
  final int baseLinePeriod;

  /// The `period` for the `IchimokuSpanB`. Default is set to `52`.
  final int leadingSpanBPeriod;

  @override
  List<Object> get props =>
      <Object>[conversionLinePeriod, baseLinePeriod, leadingSpanBPeriod];
}
