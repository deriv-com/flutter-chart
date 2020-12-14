import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/high_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hl2_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/open_value_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ma_indicator_config.dart';

/// Moving Average indicator item in the list of indicator which provide this
/// indicator's options menu.
class MAIndicatorItem extends IndicatorItem {
  /// Initializes
  const MAIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Moving Average',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MAIndicatorItemState();
}

/// MAIndicatorItem State class
class MAIndicatorItemState extends IndicatorItemState<MAIndicatorConfig> {
  /// MA type
  @protected
  MovingAverageType type;

  /// Field type
  @protected
  String field;

  /// MA period
  @protected
  int period;

  /// Different Field type indicator builders
  final Map<String, FieldIndicatorBuilder> filedIndicatorBuilders =
      <String, FieldIndicatorBuilder>{
    'close': (List<Tick> ticks) => CloseValueIndicator(ticks),
    'high': (List<Tick> ticks) => HighValueIndicator(ticks),
    'low': (List<Tick> ticks) => LowValueIndicator(ticks),
    'open': (List<Tick> ticks) => OpenValueIndicator(ticks),
    'Hl/2': (List<Tick> ticks) => HL2Indicator(ticks),
    // TODO(Ramin): Add also hlc3, hlcc4, ohlc4 Indicators.
  };

  @override
  MAIndicatorConfig createIndicatorConfig() => MAIndicatorConfig(
        (List<Tick> ticks) => MASeries.fromIndicator(
          filedIndicatorBuilders[field](ticks),
          period: period,
          type: type,
          style: const LineStyle(color: Colors.yellowAccent, thickness: 0.6),
        ),
        period: period,
        type: type,
        fieldType: field,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    type = getCurrentType();
    period = getCurrentPeriod();
    field = getCurrentField();
  }

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildMATypeMenu(),
          Row(
            children: <Widget>[
              buildPeriodField(),
              const SizedBox(width: 10),
              buildFieldTypeMenu(),
            ],
          )
        ],
      );

  /// Builds MA Field type menu
  @protected
  Widget buildFieldTypeMenu() => Row(
        children: <Widget>[
          const Text('Field: ', style: TextStyle(fontSize: 10)),
          DropdownButton<String>(
            value: getCurrentField(),
            items: filedIndicatorBuilders.keys
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
          const Text('Period: ', style: TextStyle(fontSize: 10)),
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

  /// Returns MA types dropdown menu
  @protected
  Widget buildMATypeMenu() => Row(
        children: <Widget>[
          const Text('Type: ', style: TextStyle(fontSize: 10)),
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
                type = newType;
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Gets Indicator current type.
  @protected
  MovingAverageType getCurrentType() =>
      getConfig()?.type ?? MovingAverageType.simple;

  /// Gets Indicator current filed type.
  @protected
  String getCurrentField() => getConfig()?.fieldType ?? 'close';

  /// Gets Indicator current period.
  @protected
  int getCurrentPeriod() => getConfig()?.period ?? 50;
}
