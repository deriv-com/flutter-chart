import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

/// Aroon indicator item in the list of indicator which provide this
/// indicators options menu.
class AroonIndicatorItem extends IndicatorItem {
  /// Initializes
  const AroonIndicatorItem({
    Key? key,
    AroonIndicatorConfig config = const AroonIndicatorConfig(),
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'Aroon',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      AroonIndicatorItemState();
}

/// Aroon Item State class
class AroonIndicatorItemState extends IndicatorItemState<AroonIndicatorConfig> {
  int? _period;

  @override
  AroonIndicatorConfig createIndicatorConfig() => AroonIndicatorConfig(
        period: _currentPeriod,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
        ],
      );

  Widget _buildPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _currentPeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _period = int.tryParse(text);
                } else {
                  _period = 14;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  int get _currentPeriod =>
      _period ?? (widget.config as AroonIndicatorConfig).period;
}
