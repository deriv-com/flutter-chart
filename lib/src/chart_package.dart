import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
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
  Map<String, IndicatorSeriesBuilder> _indicators =
      <String, IndicatorSeriesBuilder>{};

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Chart(
            mainSeries: widget.mainSeries,
            pipSize: widget.pipSize,
            granularity: widget.granularity,
            controller: widget.controller,
            secondarySeries: <Series>[
              ..._indicators.values
                  .where((IndicatorSeriesBuilder indicatorBuilder) =>
                      indicatorBuilder != null)
                  .map((IndicatorSeriesBuilder indicatorBuilder) =>
                      indicatorBuilder?.call(widget.mainSeries.entries))
            ],
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
                      _IndicatorsDialog(
                    ticks: widget.mainSeries.entries,
                    onIndicators: (
                      Map<String, IndicatorSeriesBuilder> indicators,
                    ) =>
                        setState(() => _indicators = indicators),
                  ),
                );
              },
            ),
          )
        ],
      );
}

class _IndicatorsDialog extends StatefulWidget {
  const _IndicatorsDialog({Key key, this.onIndicators, this.ticks})
      : super(key: key);

  final List<Tick> ticks;
  final OnIndicators onIndicators;

  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<_IndicatorsDialog> {
  static final Map<String, GlobalKey<_IndicatorItemState>> keys =
      <String, GlobalKey<_IndicatorItemState>>{
    'MA': GlobalKey<MAIndicatorSeriesState>(),
  };

  final Map<String, IndicatorSeriesBuilder> indicatorsMap =
      <String, IndicatorSeriesBuilder>{};

  final List<IndicatorItem<Series>> indicatorItems = <IndicatorItem>[];

  @override
  void initState() {
    super.initState();

    indicatorItems
      ..add(MAIndicatorItem(
        key: keys['MA'],
        ticks: widget.ticks,
        onAddIndicator: _onAddIndicator,
      ));
  }

  void _onAddIndicator(
    String key,
    IndicatorSeriesBuilder indicatorBuilder,
  ) =>
      setState(() {
        indicatorsMap[key] = indicatorBuilder;
        widget.onIndicators(indicatorsMap);
      });

  @override
  Widget build(BuildContext context) => AnimatedPopupDialog(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: indicatorItems.length,
          itemBuilder: (BuildContext context, int index) =>
              indicatorItems[index],
        ),
      );
}

typedef IndicatorSeriesBuilder = Series Function(List<Tick> ticks);
typedef OnIndicators = Function(Map<String, IndicatorSeriesBuilder> indicators);
typedef OnAddIndicator = Function(
  String key,
  IndicatorSeriesBuilder indicatorBuilder,
);

/// Indicator item in indicators dialog
abstract class IndicatorItem<T extends Series> extends StatefulWidget {
  /// Initializes
  const IndicatorItem({
    Key key,
    this.title,
    this.ticks,
    this.onAddIndicator,
  }) : super(key: key);

  /// Title
  final String title;

  final List<Tick> ticks;

  final OnAddIndicator onAddIndicator;

  @override
  _IndicatorItemState createState() => createIndicatorItemState();

  _IndicatorItemState createIndicatorItemState();
}

abstract class _IndicatorItemState extends State<IndicatorItem> {
  bool _indicatorIsActive = false;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(widget.title),
        trailing: Checkbox(
          value: _indicatorIsActive,
          onChanged: (bool newValue) => setState(
            () {
              _indicatorIsActive = newValue;

              if (newValue) {
                widget.onAddIndicator?.call(
                  _getIndicatorKey(),
                  createIndicatorSeries(),
                );
              } else {
                widget.onAddIndicator?.call(_getIndicatorKey(), null);
              }
            },
          ),
        ),
      );

  String _getIndicatorKey() => runtimeType.toString();

  IndicatorSeriesBuilder createIndicatorSeries();
}

class MAIndicatorItem extends IndicatorItem<MASeries> {
  MAIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'MAIndicator',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  _IndicatorItemState createIndicatorItemState() => MAIndicatorSeriesState();
}

class MAIndicatorSeriesState extends _IndicatorItemState {
  @override
  IndicatorSeriesBuilder createIndicatorSeries() => (List<Tick> ticks) {
        return MASeries(ticks);
      };
}
