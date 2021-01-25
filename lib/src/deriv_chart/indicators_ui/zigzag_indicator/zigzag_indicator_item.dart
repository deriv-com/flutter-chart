import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/zigzag_indicator/zigzag_indicator_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

/// Zigzag indicator item in the list of indicator which provide this
/// indicator's options menu.
class ZigZagIndicatorItem extends IndicatorItem {
  /// Initializes
  const ZigZagIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'ZigZag',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ZigZagIndicatorItemState();
}

/// ZigZagIndicatorItem State class
class ZigZagIndicatorItemState extends IndicatorItemState<ZigZagIndicatorConfig> {

  /// distance
  @protected
  int distance;

  @override
  ZigZagIndicatorConfig createIndicatorConfig() => ZigZagIndicatorConfig(
        distance: getCurrentDistance(),
      );

  @override
  Widget getIndicatorOptions() => buildDistanceField();


  /// Builds distance TextFiled
  @protected
  Widget buildDistanceField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelDistance,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: getCurrentDistance().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  distance = int.tryParse(text);
                } else {
                  distance = 10;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );



  /// Gets Indicator current period.
  @protected
  int getCurrentDistance() => distance ?? getConfig()?.distance ?? 10;

  @protected
  LineStyle getCurrentLineStyle() =>
      getConfig().lineStyle ??
      const LineStyle(color: Colors.yellowAccent, thickness: 0.6);
}
