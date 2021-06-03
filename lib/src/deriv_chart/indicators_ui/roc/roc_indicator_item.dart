import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/roc/roc_indicator_config.dart';

import 'package:flutter/material.dart';

/// ROC indicator item in the list of indicator which provide this
/// indicators options menu.
class ROCIndicatorItem extends IndicatorItem {
  /// Initializes
  const ROCIndicatorItem({
    Key key,
    ROCIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'ROC',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ROCIndicatorItemState();
}

/// ROCItem State class
class ROCIndicatorItemState extends IndicatorItemState<ROCIndicatorConfig> {
  int _period;
  String _field;

  @override
  ROCIndicatorConfig createIndicatorConfig() => ROCIndicatorConfig(
        period: _getCurrentPeriod(),
        fieldType: _getCurrentField(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildFieldTypeMenu(),
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
              initialValue: _getCurrentPeriod().toString(),
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

  int _getCurrentPeriod() =>
      _period ?? (widget.config as ROCIndicatorConfig)?.period ?? 14;

  Widget _buildFieldTypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelField,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: _getCurrentField(),
            items: IndicatorConfig.supportedFieldTypes.keys
                .map<DropdownMenuItem<String>>(
                    (String fieldType) => DropdownMenuItem<String>(
                          value: fieldType,
                          child: Text(
                            '$fieldType',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ))
                .toList(),
            onChanged: (String newField) => setState(
              () {
                _field = newField;
                updateIndicator();
              },
            ),
          )
        ],
      );

  String _getCurrentField() =>
      _field ?? (widget.config as ROCIndicatorConfig)?.fieldType ?? 'close';
}
