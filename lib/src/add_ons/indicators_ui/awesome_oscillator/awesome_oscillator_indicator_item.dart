import 'package:deriv_chart/src/add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_config.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

/// Awesome Oscillator Indicator item in the list of indicator which provide
/// this indicators options menu.
class AwesomeOscillatorIndicatorItem extends IndicatorItem {
  /// Initializes
  const AwesomeOscillatorIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    AwesomeOscillatorIndicatorConfig config =
        const AwesomeOscillatorIndicatorConfig(),
  }) : super(
          key: key,
          title: 'Awesome Oscillator Indicator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      AwesomeOscillatorIndicatorItemState();
}

/// Awesome Oscillator IndicatorItem State class
class AwesomeOscillatorIndicatorItemState
    extends IndicatorItemState<AwesomeOscillatorIndicatorConfig> {
  @override
  AwesomeOscillatorIndicatorConfig createIndicatorConfig() =>
      const AwesomeOscillatorIndicatorConfig();

  @override
  Widget getIndicatorOptions() => Container();
}
