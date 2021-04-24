

import 'package:deriv_chart/generated/l10n.dart';
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
    Key? key,
    ParabolicSARConfig config = const ParabolicSARConfig(),
    UpdateIndicator? updateIndicator,
    VoidCallback? deleteIndicator,
  }) : super(
          key: key,
          title: 'ParabolicSAR',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ParabolicSARIndicatorItemState();
}

/// ParabolicSARIndicatorItem State class
class ParabolicSARIndicatorItemState
    extends IndicatorItemState<ParabolicSARConfig> {
  double? _minAccelerationFactor;

  double? _maxAccelerationFactor;

  ScatterStyle? _scatterStyle;

  @override
  ParabolicSARConfig createIndicatorConfig() => ParabolicSARConfig(
        minAccelerationFactor: _currentMinAccelerationFactor,
        maxAccelerationFactor: _currentMaxAccelerationFactor,
        scatterStyle: _currentScatterStyle,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _buildMinAccelerationFactorField(),
              _buildColorButton(),
            ],
          ),
          _buildMaxAccelerationFactorField(),
        ],
      );

  ColorButton _buildColorButton() => ColorButton(
        color: _currentScatterStyle.color,
        onTap: () {
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) => ColorPickerSheet(
              selectedColor: _currentScatterStyle.color,
              onChanged: (Color selectedColor) {
                setState(() {
                  _scatterStyle = _currentScatterStyle.copyWith(
                    color: selectedColor,
                  );
                });
                updateIndicator();
              },
            ),
          );
        },
      );

  Widget _buildMaxAccelerationFactorField() => Row(
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
              initialValue: _currentMaxAccelerationFactor.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _maxAccelerationFactor = double.tryParse(text);
                } else {
                  _maxAccelerationFactor = 0.2;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  Widget _buildMinAccelerationFactorField() => Row(
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
              initialValue: _currentMinAccelerationFactor.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _minAccelerationFactor = double.tryParse(text);
                } else {
                  _minAccelerationFactor = 0.02;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  // TODO(Ramin): use generic type to avoid casting
  double get _currentMinAccelerationFactor =>
      _minAccelerationFactor ??
      (widget.config as ParabolicSARConfig)?.minAccelerationFactor ??
      0.02;

  double get _currentMaxAccelerationFactor =>
      _maxAccelerationFactor ??
      (widget.config as ParabolicSARConfig)?.maxAccelerationFactor ??
      0.2;

  ScatterStyle get _currentScatterStyle =>
      _scatterStyle ??
      (widget.config as ParabolicSARConfig)?.scatterStyle ??
      const ScatterStyle(color: Colors.yellowAccent);
}
