import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
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
class RainbowIndicatorItem extends IndicatorItem {
  /// Initializes
  const RainbowIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Rainbow Indicator',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      RainbowIndicatorItemState();
}

/// Rainbow IndicatorItem State class
class RainbowIndicatorItemState extends MAIndicatorItemState {
  /// Rainbow MA bands count
  @protected
  int bandsCount;

  @override
  MAIndicatorConfig createIndicatorConfig() => RainbowIndicatorConfig(
        bandsCount: getCurrentBandsCount(),
        rainbowColors: getCurrentRainbowColors(),
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        fieldType: getCurrentField(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildMATypeMenu(),
          Row(
            children: <Widget>[
              buildPeriodField(),
              const SizedBox(width: 10),
              buildFieldTypeMenu()
            ],
          ),
          buildBandsCountField(),
        ],
      );

  @protected
  Widget buildBandsCountField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelBandsCount,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(height: 2),
          Slider(
            value: getCurrentBandsCount().toDouble(),
            min: 1,
            max: 20,
            divisions: 20,
            label: "${getCurrentBandsCount()}",
            onChanged: (value) {
              setState(() {
                bandsCount = value.toInt();
              });
              updateIndicator();
            },
          ),
        ],
      );

  /// Gets Indicator current period.
  @protected
  int getCurrentBandsCount() {
    final RainbowIndicatorConfig config = getConfig();
    return bandsCount ?? config?.bandsCount ?? 10;
  }

  /// Gets Indicator current period.
  @protected
  int getCurrentPeriod() => period ?? getConfig()?.period ?? 2;

  @protected
  List<Color> getCurrentRainbowColors() {
    final int bands = getCurrentBandsCount();
    var minHue = 240, maxHue = 0;
    List<Color> rainbow = [];
    for (int i = 0; i < bands; i++) {
      double curPercent = i / bands;
      var bandColor = HSLColor.fromAHSL(
          1, ((curPercent * (maxHue - minHue)) + minHue), 1, 0.5);
      rainbow.add(bandColor.toColor());
    }
    return rainbow;
  }
}
