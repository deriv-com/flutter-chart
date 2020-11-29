import 'dart:ui';

import 'package:deriv_chart/src/chart.dart';
import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/chart_controller.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'callbacks.dart';

/// A wrapper around the [Chart] which handles adding indicators to the chart.
class ChartPackage extends StatefulWidget {
  /// Initializes
  const ChartPackage({
    Key key,
    this.mainSeries,
    this.markerSeries,
    this.controller,
    this.pipSize,
    this.granularity,
    this.onCrosshairAppeared,
    this.onVisibleAreaChanged,
    this.theme,
    this.annotations,
    this.isLive,
    this.opacity = 1.0,
  }) : super(key: key);

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// Open position marker series.
  final MarkerSeries markerSeries;

  /// Chart's controller
  final ChartController controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when crosshair details appear after long press.
  final VoidCallback onCrosshairAppeared;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback onVisibleAreaChanged;

  /// Chart's theme.
  final ChartTheme theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>> annotations;

  /// Whether the chart should be showing live data or not.
  ///
  /// In case of being true the chart will keep auto-scrolling when its visible area
  /// is on the newest ticks/candles.
  final bool isLive;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  @override
  _ChartPackageState createState() => _ChartPackageState();
}

class _ChartPackageState extends State<ChartPackage> {
  final List<Series> _indicators = <Series>[];

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Chart(
            mainSeries: widget.mainSeries,
            pipSize: widget.pipSize,
            granularity: widget.granularity,
            controller: widget.controller,
            secondarySeries: _indicators,
            markerSeries: widget.markerSeries,
            theme: widget.theme,
            onCrosshairAppeared: widget.onCrosshairAppeared,
            isLive: widget.isLive,
            opacity: widget.opacity,
            annotations: widget.annotations,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.architecture),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (
                    BuildContext context,
                  ) =>
                      _IndicatorsDialog(indicators: _indicators),
                );
              },
            ),
          )
        ],
      );
}

class _IndicatorsDialog extends StatefulWidget {
  const _IndicatorsDialog({Key key, this.indicators}) : super(key: key);

  final List<Series> indicators;

  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<_IndicatorsDialog> {
  @override
  Widget build(BuildContext context) => AnimatedPopupDialog(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const <Widget>[
        IndicatorItem(
          title: 'Moving Average',
        )
      ],
    ),
  );
}

/// Indicator item in indicators dialog
class IndicatorItem extends StatefulWidget {
  /// Initializes
  const IndicatorItem({Key key, this.title}) : super(key: key);

  /// Title
  final String title;

  @override
  _IndicatorItemState createState() => _IndicatorItemState();
}

class _IndicatorItemState extends State<IndicatorItem> {
  bool _indicatorIsActive = false;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(widget.title),
        trailing: Checkbox(
          value: _indicatorIsActive,
          onChanged: (bool newValue) => setState(
            () => _indicatorIsActive = newValue,
          ),
        ),
      );
}
