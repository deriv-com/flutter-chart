import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/top_layer/deriv_chart/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
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
    MAEnvIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'MA Envelope Indicator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MAEnvIndicatorItemState();
}

/// MAEnvIndicatorItem State class
class MAEnvIndicatorItemState extends MAIndicatorItemState {
  /// MA Env shift
  @protected
  double shift;

  /// Field ShiftType
  @protected
  ShiftType shiftType;

  @override
  MAEnvIndicatorConfig createIndicatorConfig() => MAEnvIndicatorConfig(
        shiftType: getCurrentShiftType(),
        shift: getCurrentShift(),
        fieldType: getCurrentField(),
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
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
                  shift = double.tryParse(text);
                } else {
                  shift = 5;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Returns shift types dropdown menu
  @protected
  Widget buildShiftTypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelShiftType,
            style: const TextStyle(fontSize: 10),
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
                shiftType = newType;
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Gets Indicator current type.
  @protected
  ShiftType getCurrentShiftType() {
    final MAEnvIndicatorConfig config = (widget.config as MAEnvIndicatorConfig);
    return shiftType ?? config?.shiftType ?? ShiftType.percent;
  }

  /// Gets Indicator current period.
  @protected
  double getCurrentShift() {
    final MAEnvIndicatorConfig config = (widget.config as MAEnvIndicatorConfig);
    return shift ?? config?.shift ?? 5;
  }

  @protected
  LineStyle getCurrentLineStyle() =>
      (widget.config as MAEnvIndicatorConfig).lineStyle ??
      const LineStyle(color: Colors.yellowAccent, thickness: 0.6);
}
