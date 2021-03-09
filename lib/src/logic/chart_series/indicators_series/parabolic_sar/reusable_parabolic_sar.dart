import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// A version of Parabolic SAR indicator specifically to be usable in [AbstractSingleIndicatorSeries].
///
/// In [AbstractSingleIndicatorSeries] for better performance when a new tick is
/// added or the last tick gets updated we don't recalculate all the indicators
/// results and just for the new tick.
/// If we were in granularities other than `1 tick` mode, calculating result for
/// the last index for the first time is no problem but when we want to update
/// the result for the last index when tha chart's last tick gets updated that
/// would make [ParabolicSarIndicator] internal variables to become incorrect.
///
/// Here to fix that whenever we want to calculate the result for the last index
/// we make a backup for those internal variables and after calculating we reset them.
class ReusableParabolicSarIndicator extends ParabolicSarIndicator<Tick> {
  /// Initializes PSAR indicator.
  ReusableParabolicSarIndicator(
    IndicatorInput indicatorInput, {
    double aF = 0.02,
    double maxA = 0.2,
    double increment = 0.02,
  }) : super(indicatorInput, aF: aF, maxA: maxA, increment: increment);

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
  void copyValuesFrom(covariant ReusableParabolicSarIndicator other) {
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
