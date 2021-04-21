import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/alligator/alligator_indicator_config.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

/// Alligator indicator item in the list of indicator which provide this
/// indicators options menu.
class AlligatorIndicatorItem extends IndicatorItem {
  /// Initializes
  const AlligatorIndicatorItem({
    Key key,
    AlligatorIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'Alligator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      AlligatorIndicatorItemState();
}

/// AlligatorIndicatorItem State class
class AlligatorIndicatorItemState
    extends IndicatorItemState<AlligatorIndicatorConfig> {
  int _jawOffset;
  int _jawPeriod;
  int _teethOffset;
  int _teethPeriod;
  int _lipsOffset;
  int _lipsPeriod;

  @override
  AlligatorIndicatorConfig createIndicatorConfig() => AlligatorIndicatorConfig(
        jawPeriod: currentJawPeriod,
        jawOffset: currentJawOffset,
        teethPeriod: currentTeethPeriod,
        teethOffset: currentTeethOffset,
        lipsPeriod: currentLipsPeriod,
        lipsOffset: currentLipsOffset,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildJawPeriodField(),
          buildJawOffsetField(),
          buildTeethPeriodField(),
          buildTeethOffsetField(),
          buildLipsPeriodField(),
          buildLipsOffsetField(),
        ],
      );

  /// Builds jaw offset
  @protected
  Widget buildJawOffsetField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelJawOffset,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentJawOffset.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _jawOffset = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentJawOffset',
            ),
          ),
        ],
      );

  /// Builds jaw period
  @protected
  Widget buildJawPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelJawPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentJawPeriod.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _jawPeriod = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentJawPeriod',
            ),
          ),
        ],
      );

  /// Builds teeth offset
  @protected
  Widget buildTeethOffsetField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelTeethOffset,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentTeethOffset.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _teethOffset = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentTeethOffset',
            ),
          ),
        ],
      );

  /// Builds teeth period
  @protected
  Widget buildTeethPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelTeethPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentTeethPeriod.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _teethPeriod = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentTeethPeriod',
            ),
          ),
        ],
      );

  /// Builds lips offset
  @protected
  Widget buildLipsOffsetField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelLipsOffset,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentLipsOffset.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _lipsOffset = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentLipsOffset',
            ),
          ),
        ],
      );

  /// Builds lips period
  @protected
  Widget buildLipsPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelLipsPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: currentLipsPeriod.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _lipsPeriod = value.toInt();
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '$currentLipsPeriod',
            ),
          ),
        ],
      );

  /// Gets current jaw offset.
  @protected
  int get currentJawOffset =>
      _jawOffset ?? (widget.config as AlligatorIndicatorConfig)?.jawOffset ?? 8;

  /// Gets current jaw period.
  @protected
  int get currentJawPeriod =>
      _jawPeriod ??
      (widget.config as AlligatorIndicatorConfig)?.jawPeriod ??
      13;

  /// Gets current teeth offset.
  @protected
  int get currentTeethOffset =>
      _teethOffset ??
      (widget.config as AlligatorIndicatorConfig)?.teethOffset ??
      5;

  /// Gets current teeth period.
  @protected
  int get currentTeethPeriod =>
      _teethPeriod ??
      (widget.config as AlligatorIndicatorConfig)?.teethPeriod ??
      8;

  /// Gets current lips period.
  @protected
  int get currentLipsPeriod =>
      _lipsPeriod ??
      (widget.config as AlligatorIndicatorConfig)?.lipsPeriod ??
      5;

  /// Gets current lips offset.
  @protected
  int get currentLipsOffset =>
      _lipsOffset ??
      (widget.config as AlligatorIndicatorConfig)?.lipsOffset ??
      3;
}
