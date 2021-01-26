import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_env_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ma_env_indicator_config.dart';

/// Moving Average Envelope indicator item in the list of indicator which provide this
/// indicators options menu.
class MAEnvIndicatorItem extends IndicatorItem {
  /// Initializes
  const MAEnvIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'MA Envelope Indicator',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MAEnvIndicatorItemState();
}

/// MAEnvIndicatorItem State class
class MAEnvIndicatorItemState extends IndicatorItemState<MAEnvIndicatorConfig> {
  /// MA type
  @protected
  MovingAverageType movingAverageType;

  /// Field type
  @protected
  String field;

  /// MA period
  @protected
  int period;

  /// MA Env shift
  @protected
  int shift;

  /// Field ShiftType
  @protected
  ShiftType shiftType;

  @override
  MAEnvIndicatorConfig createIndicatorConfig() => MAEnvIndicatorConfig(
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        fieldType: getCurrentField(),
        shiftType: getCurrentShiftType(),
        shift: getCurrentShift(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildPeriodField(),
          buildFieldTypeMenu(),
          buildShiftTypeMenu(),
          buildShiftField(),
          buildMATypeMenu(),
        ],
      );

  /// Builds MA Field type menu
  @protected
  Widget buildFieldTypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelField,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: getCurrentField(),
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
                field = newField;
                updateIndicator();
              },
            ),
          )
        ],
      );

  /// Builds Period TextFiled
  @protected
  Widget buildPeriodField() => Row(
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
              initialValue: getCurrentPeriod().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  period = int.tryParse(text);
                } else {
                  period = 15;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Builds Period TextFiled
  @protected
  Widget buildShiftField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelShift,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: getCurrentShift().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  shift = int.tryParse(text);
                } else {
                  shift = 5;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Returns MA types dropdown menu
  @protected
  Widget buildMATypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelType,
            style: TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<MovingAverageType>(
            value: getCurrentType(),
            items: MovingAverageType.values
                .map<DropdownMenuItem<MovingAverageType>>(
                    (MovingAverageType type) =>
                        DropdownMenuItem<MovingAverageType>(
                          value: type,
                          child: Text(
                            '${getEnumValue(type)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ))
                .toList(),
            onChanged: (MovingAverageType newType) => setState(
              () {
                movingAverageType = newType;
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Returns MA types dropdown menu
  @protected
  Widget buildShiftTypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelShiftType,
            style: TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<ShiftType>(
            value: getCurrentShiftType(),
            items: ShiftType.values
                .map<DropdownMenuItem<ShiftType>>(
                    (ShiftType type) => DropdownMenuItem<ShiftType>(
                          value: type,
                          child: Text(
                            '${getEnumValue(type)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ))
                .toList(),
            onChanged: (ShiftType newType) => setState(
              () {
                // type = newType;
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Gets Indicator current type.
  @protected
  MovingAverageType getCurrentType() =>
      movingAverageType ??
      getConfig()?.movingAverageType ??
      MovingAverageType.simple;

  /// Gets Indicator current type.
  @protected
  ShiftType getCurrentShiftType() =>
      shiftType ?? getConfig()?.shiftType ?? ShiftType.percent;

  /// Gets Indicator current filed type.
  @protected
  String getCurrentField() => field ?? getConfig()?.fieldType ?? 'close';

  /// Gets Indicator current period.
  @protected
  int getCurrentPeriod() => period ?? getConfig()?.period ?? 50;

  /// Gets Indicator current period.
  @protected
  int getCurrentShift() => shift ?? getConfig()?.shift ?? 5;

  @protected
  LineStyle getCurrentLineStyle() =>
      getConfig().lineStyle ??
      const LineStyle(color: Colors.yellowAccent, thickness: 0.6);
}
