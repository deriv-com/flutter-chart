import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_button.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_picker_sheet.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'parabolic_sar_indicator_config.dart';

/// ParabolicSAR indicator item in the list of indicator which provide this
/// indicator's options menu.
class ParabolicSARIndicatorItem extends IndicatorItem {
  /// Initializes
  const ParabolicSARIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Parabolic SAR',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ParabolicSARIndicatorItemState();
}

/// ParabolicSARIndicatorItem State class
class ParabolicSARIndicatorItemState
    extends IndicatorItemState<ParabolicSARConfig> {
  /// Min AccelerationFactor
  @protected
  double minAccelerationFactor;

  /// Min AccelerationFactor
  @protected
  double maxAccelerationFactor;

  /// Scatter points style
  @protected
  ScatterStyle scatterStyle;

  @override
  ParabolicSARConfig createIndicatorConfig() => ParabolicSARConfig(
        minAccelerationFactor: currentMinAccelerationFactor,
        maxAccelerationFactor: currentMaxAccelerationFactor,
        scatterStyle: currentScatterStyle,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              buildMinAccelerationFactorField(),
              _buildColorButton(),
            ],
          ),
          buildMaxAccelerationFactorField(),
        ],
      );

  ColorButton _buildColorButton() => ColorButton(
        color: currentScatterStyle.color,
        onTap: () {
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) => ColorPickerSheet(
              selectedColor: currentScatterStyle.color,
              onChanged: (Color selectedColor) {
                setState(() {
                  scatterStyle = currentScatterStyle.copyWith(
                    color: selectedColor,
                  );
                });
                updateIndicator();
              },
            ),
          );
        },
      );

  /// Max AF widget.
  @protected
  Widget buildMaxAccelerationFactorField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelMaxAF,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 30,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: currentMaxAccelerationFactor.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  maxAccelerationFactor = double.tryParse(text);
                } else {
                  maxAccelerationFactor = 0.2;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Min AF widget.
  @protected
  Widget buildMinAccelerationFactorField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelMinAF,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 30,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: currentMinAccelerationFactor.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  minAccelerationFactor = double.tryParse(text);
                } else {
                  minAccelerationFactor = 0.02;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  /// Gets Indicator current minAccelerationFactor.
  @protected
  double get currentMinAccelerationFactor =>
      minAccelerationFactor ?? getConfig()?.minAccelerationFactor ?? 0.02;

  /// Gets Indicator current minAccelerationFactor.
  @protected
  double get currentMaxAccelerationFactor =>
      maxAccelerationFactor ?? getConfig()?.maxAccelerationFactor ?? 0.2;

  /// Creates Line style
  @protected
  ScatterStyle get currentScatterStyle =>
      scatterStyle ??
      getConfig()?.scatterStyle ??
      const ScatterStyle(color: Colors.yellowAccent);
}
