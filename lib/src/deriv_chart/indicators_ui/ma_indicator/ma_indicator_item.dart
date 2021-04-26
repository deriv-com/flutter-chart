

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_button.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_picker_sheet.dart';
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
    Key? key,
    MAIndicatorConfig config = const MAIndicatorConfig(),
    UpdateIndicator? updateIndicator,
    VoidCallback? deleteIndicator,
  }) : super(
          key: key,
          title: 'Moving Average',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MAIndicatorItemState();
}

/// MAIndicatorItem State class
class MAIndicatorItemState extends IndicatorItemState<MAIndicatorConfig> {
  /// MA type
  @protected
  MovingAverageType? type;

  /// Field type
  @protected
  String? field;

  /// MA period
  @protected
  int? period;

  /// MA period
  @protected
  int? offset;

  /// MA line style
  @protected
  LineStyle? lineStyle;

  @override
  MAIndicatorConfig createIndicatorConfig() => MAIndicatorConfig(
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        fieldType: getCurrentField(),
        offset: currentOffset,
        lineStyle: getCurrentLineStyle(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ColorButton(
            color: getCurrentLineStyle().color,
            onTap: () {
              showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) => ColorPickerSheet(
                  selectedColor: getCurrentLineStyle().color,
                  onChanged: (Color selectedColor) {
                    setState(() {
                      lineStyle =
                          getCurrentLineStyle().copyWith(color: selectedColor);
                    });
                    updateIndicator();
                  },
                ),
              );
            },
          ),
          buildMATypeMenu(),
          Row(
            children: <Widget>[
              buildPeriodField(),
              const SizedBox(width: 10),
              buildFieldTypeMenu(),
            ],
          ),
          buildOffsetField(),
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
            onChanged: (String? newField) => setState(
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

  /// Builds offset TextFiled
  @protected
  Widget buildOffsetField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelOffset,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentOffset.toDouble(),
              onChanged: (double value) {
                setState(() {
                  offset = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentOffset',
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
            style: const TextStyle(fontSize: 10),
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
            onChanged: (MovingAverageType? newType) => setState(
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
      type ??
      (widget.config as MAIndicatorConfig).movingAverageType;

  /// Gets Indicator current filed type.
  @protected
  String getCurrentField() =>
      field ?? (widget.config as MAIndicatorConfig).fieldType;

  /// Gets Indicator current period.
  @protected
  int getCurrentPeriod() =>
      period ?? (widget.config as MAIndicatorConfig).period;

  /// Gets Indicator current period.
  @protected
  int get currentOffset =>
      offset ?? (widget.config as MAIndicatorConfig).offset;

  /// Gets Indicator current line style.
  @protected
  LineStyle getCurrentLineStyle() =>
      lineStyle ??
      (widget.config as MAIndicatorConfig).lineStyle;
}
