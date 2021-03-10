import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ichimoku_cloud_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/ichimoku_clouds_options.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';

/// Ichimoku Cloud Indicator Config
class IchimokuCloudIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const IchimokuCloudIndicatorConfig({
    this.baseLinePeriod = 26,
    this.conversionLinePeriod = 9,
    this.laggingSpanOffset = -26,
    this.spanBPeriod = 52,
  }) : super();

  /// The period to calculate the Conversion Line value.
  final int conversionLinePeriod;

  /// The period to calculate the Base Line value.
  final int baseLinePeriod;

  /// The period to calculate the Span B value.
  final int spanBPeriod;

  /// The period to calculate the Base Line value.
  final int laggingSpanOffset;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      IchimokuCloudSeries(indicatorInput,
          config: this,
          ichimokuCloudOptions: IchimokuCloudOptions(
            baseLinePeriod: baseLinePeriod,
            conversionLinePeriod: conversionLinePeriod,
            leadingSpanBPeriod: spanBPeriod,
          ));
}
