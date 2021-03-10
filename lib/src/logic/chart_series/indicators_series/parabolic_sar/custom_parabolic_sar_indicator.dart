import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// A version of Parabolic SAR indicator specifically to be suitable for
/// [AbstractSingleIndicatorSeries].
///
/// In [AbstractSingleIndicatorSeries] for better performance, when a new tick is
/// added or the last tick gets updated, we don't recalculate indicator's result
/// for all indices and just for the last tick.
/// If we were in granularities other than `1 tick` mode, calculating the result
/// of the last index for the first time is no problem but when the chart's last
/// tick gets updated and after we update the result for this index, internal
/// variables of [ParabolicSarIndicator] become incorrect.
/// (e.g. [accelerationFactor])
///
/// Here to fix it, whenever we want to calculate the result for the last index
/// we make a backup of those internal variables and after calculating the result
/// we reset them to backup values.
class CustomParabolicSarIndicator extends ParabolicSarIndicator<Tick> {
  /// Initializes PSAR indicator.
  CustomParabolicSarIndicator(
    IndicatorInput indicatorInput, {
    double accelerationStart = 0.02,
    double maxAcceleration = 0.2,
    double accelerationIncrement = 0.02,
  }) : super(
          indicatorInput,
          accelerationStart: accelerationStart,
          maxAcceleration: maxAcceleration,
          accelerationIncrement: accelerationIncrement,
        );

  // Backup for PSAR internal variables.
  double _backupAccelerationFactor;
  bool _backupCurrentTrend;
  int _backupStartTrendIndex;
  double _backupCurrentExtremePoint;
  double _backupMinMaxExtremePoint;

  @override
  Tick calculate(int index) {
    if (index == entries.length - 1) {
      _backupAccelerationFactor = accelerationFactor;
      _backupCurrentTrend = currentTrend;
      _backupStartTrendIndex = startTrendIndex;
      _backupCurrentExtremePoint = currentExtremePoint;
      _backupMinMaxExtremePoint = minMaxExtremePoint;

      final Tick result = super.calculate(index);

      accelerationFactor = _backupAccelerationFactor;
      currentTrend = _backupCurrentTrend;
      startTrendIndex = _backupStartTrendIndex;
      currentExtremePoint = _backupCurrentExtremePoint;
      minMaxExtremePoint = _backupMinMaxExtremePoint;
      return result;
    }

    return super.calculate(index);
  }

  @override
  void copyValuesFrom(covariant CustomParabolicSarIndicator other) {
    super.copyValuesFrom(other);
    currentTrend = other._backupCurrentTrend;
    accelerationFactor = other._backupAccelerationFactor;
    startTrendIndex = other._backupStartTrendIndex;
    currentExtremePoint = other._backupCurrentExtremePoint;
    minMaxExtremePoint = other._backupMinMaxExtremePoint;

    if (entries.length > other.entries.length) {
      for (int i = other.entries.length - 1; i < entries.length - 1; i++) {
        invalidate(i);
        final Tick resultForLastIndex = super.calculate(i);
        results[i] = resultForLastIndex;
      }
    }
  }
}
