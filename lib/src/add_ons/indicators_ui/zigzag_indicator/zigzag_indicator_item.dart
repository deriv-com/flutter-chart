import 'package:deriv_chart/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'zigzag_indicator_config.dart';

/// Zigzag indicator item in the list of indicator which provide this
/// indicator's options menu.
class ZigZagIndicatorItem extends IndicatorItem {
  /// Initializes
  const ZigZagIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    ZigZagIndicatorConfig config = const ZigZagIndicatorConfig(),
  }) : super(
          key: key,
          title: 'ZigZag',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ZigZagIndicatorItemState();
}

/// ZigZagIndicatorItem State class
class ZigZagIndicatorItemState
    extends IndicatorItemState<ZigZagIndicatorConfig> {
  /// distance
  @protected
  double? distance;

  @override
  ZigZagIndicatorConfig createIndicatorConfig() =>
      (widget.config as ZigZagIndicatorConfig).copyWith(
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
                  distance = double.tryParse(text);
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
  double getCurrentDistance() =>
      distance ?? (widget.config as ZigZagIndicatorConfig).distance;
}
