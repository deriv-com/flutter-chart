import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/fcb_indicator/fcb_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rainbow_indicator/rainbow_indicator_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';

/// Rainbow indicator item in the list of indicator which provide this
/// indicators options menu.
class FractalChaosBandIndicatorItem extends IndicatorItem {
  /// Initializes
  const FractalChaosBandIndicatorItem({
    Key key,
    FractalChaosBandIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'Fractal Chaos Band Indicator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      FractalChaosBandIndicatorItemState();
}

/// Rainbow IndicatorItem State class
class FractalChaosBandIndicatorItemState
    extends IndicatorItemState<FractalChaosBandIndicatorConfig> {
  /// Rainbow MA bands count
  @protected
  bool _channelFill;

  @override
  FractalChaosBandIndicatorConfig createIndicatorConfig() =>
      FractalChaosBandIndicatorConfig(
        channelFill: currentChannelFill,
      );

  @override
  Widget getIndicatorOptions() => Container();

  // TODO: will add this option after apply the channel fill
  /// Builds show lines option
  @protected
  Widget buildShowChannelFillField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelLipsPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: currentChannelFill,
            onChanged: (bool value) {
              setState(() {
                _channelFill = value;
              });
              updateIndicator();
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          )
        ],
      );

  /// Gets current show lines.
  @protected
  bool get currentChannelFill =>
      _channelFill ??
      (widget.config as FractalChaosBandIndicatorConfig)?.channelFill ??
      false;
}
