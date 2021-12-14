import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/dropdown_menu.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/field_widget.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'smi_indicator_config.dart';

/// SMI indicator item in the list of indicator which provide this
/// indicators options menu.
class SMIIndicatorItem extends IndicatorItem {
  /// Initializes
  const SMIIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    SMIIndicatorConfig config = const SMIIndicatorConfig(),
  }) : super(
          key: key,
          title: 'SMI',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      SMIIndicatorItemState();
}

/// SMIItem State class
class SMIIndicatorItemState extends IndicatorItemState<SMIIndicatorConfig> {
  int? _period;
  int? _smoothingPeriod;
  int? _doubleSmoothingPeriod;
  double? _overboughtValue;
  double? _oversoldValue;
  MovingAverageType? _maType;
  int? _signalPeriod;

  @override
  SMIIndicatorConfig createIndicatorConfig() => SMIIndicatorConfig(
        period: _currentPeriod,
        smoothingPeriod: _currentSmoothingPeriod,
        doubleSmoothingPeriod: _currentDoubleSmoothingPeriod,
        overboughtValue: _currentOverboughtValue,
        oversoldValue: _currentOversoldValue,
        maType: _currentMAType,
        signalPeriod: _currentSignalPeriod,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildSmoothingPeriodField(),
          _buildDoubleSmoothingPeriodField(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
          _buildMATypeField(),
          _buildSignalPeriodField(),
        ],
      );

  Widget _buildPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelPeriod,
        initialValue: _currentPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _period = int.tryParse(text);
          } else {
            _period = 10;
          }
          updateIndicator();
        },
      );

  Widget _buildSmoothingPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelSmoothingPeriod,
        initialValue: _currentSmoothingPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _smoothingPeriod = int.tryParse(text);
          } else {
            _smoothingPeriod = 3;
          }
          updateIndicator();
        },
      );

  Widget _buildDoubleSmoothingPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelDoubleSmoothingPeriod,
        initialValue: _currentDoubleSmoothingPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _doubleSmoothingPeriod = int.tryParse(text);
          } else {
            _doubleSmoothingPeriod = 3;
          }
          updateIndicator();
        },
      );

  Widget _buildSignalPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelSignalPeriod,
        initialValue: _currentSignalPeriod.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _signalPeriod = int.tryParse(text);
          } else {
            _signalPeriod = 10;
          }
          updateIndicator();
        },
      );

  int get _currentPeriod =>
      _period ?? (widget.config as SMIIndicatorConfig).period;

  int get _currentSmoothingPeriod =>
      _smoothingPeriod ?? (widget.config as SMIIndicatorConfig).smoothingPeriod;

  int get _currentDoubleSmoothingPeriod =>
      _doubleSmoothingPeriod ??
      (widget.config as SMIIndicatorConfig).doubleSmoothingPeriod;

  int get _currentSignalPeriod =>
      _signalPeriod ?? (widget.config as SMIIndicatorConfig).signalPeriod;

  Widget _buildOverBoughtPriceField() => FieldWidget(
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        initialValue: _currentOverboughtValue.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overboughtValue = double.tryParse(text);
          } else {
            _overboughtValue = 80;
          }
          updateIndicator();
        },
      );

  double get _currentOverboughtValue =>
      _overboughtValue ?? (widget.config as SMIIndicatorConfig).overboughtValue;

  Widget _buildOverSoldPriceField() => FieldWidget(
        label: ChartLocalization.of(context).labelOverSoldPrice,
        initialValue: _currentOversoldValue.toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _oversoldValue = double.tryParse(text);
          } else {
            _oversoldValue = 20;
          }
          updateIndicator();
        },
      );

  double get _currentOversoldValue =>
      _oversoldValue ?? (widget.config as SMIIndicatorConfig).oversoldValue;

  MovingAverageType get _currentMAType =>
      _maType ?? (widget.config as SMIIndicatorConfig).maType;

  Widget _buildMATypeField() => DropdownMenu<MovingAverageType>(
        initialValue: _currentMAType,
        items: MovingAverageType.values,
        label: ChartLocalization.of(context).labelType,
        labelForItem: (MovingAverageType type) => getEnumValue(type),
        onItemSelected: (MovingAverageType? newType) => setState(
          () {
            _maType = newType ?? MovingAverageType.simple;
            updateIndicator();
          },
        ),
      );
}
