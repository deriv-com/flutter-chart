import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'parabolic_sar_indicator_config.dart';

/// ParabolicSAR indicator item in the list of indicator which provide this
/// indicator's options menu.
class ParabolicSARIndicatorItem extends IndicatorItem {
  /// Initializes
  const ParabolicSARIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Parabolic SAR',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ParabolicSARIndicatorItemState();
}

/// ParabolicSARIndicatorItem State class
class ParabolicSARIndicatorItemState
    extends IndicatorItemState<ParabolicSARConfig> {
  /// Min AccelerationFactor
  @protected
  double minAccelerationFactor;

  /// Min AccelerationFactor
  @protected
  double maxAccelerationFactor;

  @override
  ParabolicSARConfig createIndicatorConfig() => ParabolicSARConfig(
        minAccelerationFactor: currentMinAccelerationFactor,
        maxAccelerationFactor: currentMaxAccelerationFactor,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildMinAccelerationFactorField(),
          buildMaxAccelerationFactorField(),
        ],
      );

  ///
  @protected
  Widget buildMaxAccelerationFactorField() => Row(
        children: <Widget>[
          Text(
            'Max AF: ${currentMaxAccelerationFactor.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentMaxAccelerationFactor,
              onChanged: (double value) {
                setState(() {
                  maxAccelerationFactor = roundDouble(value, 2);
                  updateIndicator();
                });
              },
              divisions: 10000,
              max: 100,
            ),
          ),
        ],
      );

  ///
  @protected
  Widget buildMinAccelerationFactorField() => Row(
        children: <Widget>[
          Text(
            'Min AF: ${currentMinAccelerationFactor.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentMinAccelerationFactor,
              onChanged: (double value) {
                setState(() {
                  minAccelerationFactor = roundDouble(value, 2);
                  updateIndicator();
                });
              },
              divisions: 10000,
              max: 100,
            ),
          ),
        ],
      );

  /// Gets Indicator current minAccelerationFactor.
  @protected
  double get currentMinAccelerationFactor =>
      minAccelerationFactor ?? getConfig()?.minAccelerationFactor ?? 0.02;

  /// Gets Indicator current minAccelerationFactor.
  @protected
  double get currentMaxAccelerationFactor =>
      maxAccelerationFactor ?? getConfig()?.maxAccelerationFactor ?? 0.2;

  /// Creates Line style
  @protected
  LineStyle getCurrentLineStyle() =>
      getConfig().lineStyle ??
      const LineStyle(color: Colors.yellowAccent, thickness: 0.6);
}
