import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/chart.dart';
import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/chart_controller.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/indicators/indicators.dart';
import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

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
  IndicatorsRepository _indicatorsRepo = IndicatorsRepository();

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Chart(
            mainSeries: widget.mainSeries,
            pipSize: widget.pipSize,
            granularity: widget.granularity,
            controller: widget.controller,
            secondarySeries: <Series>[
              ..._indicatorsRepo.indicators.values
                  .where((IndicatorConfig indicatorConfig) =>
                      indicatorConfig != null)
                  .map((IndicatorConfig indicatorConfig) =>
                      indicatorConfig?.builder?.call(widget.mainSeries.entries))
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
                      MultiProvider(
                    providers: <Provider>[
                      Provider<IndicatorsRepository>.value(
                          value: _indicatorsRepo)
                    ],
                    child: _IndicatorsDialog(
                      ticks: widget.mainSeries.entries,
                      onAddIndicator: (
                        String key,
                        IndicatorConfig indicatorBuilder,
                      ) =>
                          setState(() => _indicatorsRepo.indicators[key] =
                              indicatorBuilder),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      );
}

class IndicatorsRepository {
  final Map<String, IndicatorConfig> _indicators;

  Map<String, IndicatorConfig> get indicators => _indicators;

  IndicatorsRepository() : _indicators = <String, IndicatorConfig>{};

  bool isIndicatorActive(String key) => _indicators[key] != null;

  IndicatorConfig getIndicator(String key) => _indicators[key];
}

class _IndicatorsDialog extends StatefulWidget {
  const _IndicatorsDialog({
    Key key,
    this.onAddIndicator,
    this.ticks,
  }) : super(key: key);

  final List<Tick> ticks;
  final OnAddIndicator onAddIndicator;

  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<_IndicatorsDialog> {
  final List<IndicatorItem> indicatorItems = <IndicatorItem>[];

  @override
  void initState() {
    super.initState();

    indicatorItems
      ..add(MAIndicatorItem(
        ticks: widget.ticks,
        onAddIndicator: widget.onAddIndicator,
      ));
  }

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

typedef IndicatorBuilder = Series Function(List<Tick> ticks);
typedef OnAddIndicator = Function(
  String key,
  IndicatorConfig indicatorConfig,
);

/// Indicator config
abstract class IndicatorConfig {
  /// Initializes
  IndicatorConfig(this.builder);

  /// Indicator series builder
  final IndicatorBuilder builder;
}

class MAIndicatorConfig extends IndicatorConfig {
  /// Initializes
  MAIndicatorConfig(
    IndicatorBuilder indicatorBuilder, {
    this.period,
    this.type,
  }) : super(indicatorBuilder);

  /// Moving Average period
  final int period;

  /// Moving Average type
  final MovingAverageType type;
}

/// Indicator item in indicators dialog
abstract class IndicatorItem extends StatefulWidget {
  /// Initializes
  const IndicatorItem({
    Key key,
    this.title,
    this.ticks,
    this.onAddIndicator,
  }) : super(key: key);

  /// Title
  final String title;

  /// List of entries to calculate indicator on.
  final List<Tick> ticks;

  /// A callback which will be called when want to add this indicator.
  final OnAddIndicator onAddIndicator;

  @override
  _IndicatorItemState createState() => createIndicatorItemState();

  @protected
  _IndicatorItemState createIndicatorItemState();
}

abstract class _IndicatorItemState<T extends IndicatorConfig>
    extends State<IndicatorItem> {
  IndicatorsRepository indicatorsRepo;

  /// Gets the [IndicatorConfig] of this [IndicatorItem]
  T getConfig() => indicatorsRepo != null
      ? indicatorsRepo?.indicators[getIndicatorKey()]
      : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    indicatorsRepo = Provider.of<IndicatorsRepository>(context);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        subtitle: Text(widget.title),
        title: getIndicatorOptions(),
        trailing: Checkbox(
          value: indicatorsRepo.isIndicatorActive(getIndicatorKey()),
          onChanged: (bool newValue) => setState(
            () {
              if (newValue) {
                widget.onAddIndicator?.call(
                  getIndicatorKey(),
                  createIndicatorConfig(),
                );
              } else {
                widget.onAddIndicator?.call(getIndicatorKey(), null);
              }
            },
          ),
        ),
      );

  @protected
  String getIndicatorKey() => runtimeType.toString();

  /// Returns the [IndicatorConfig] which can be used to create the [Series] for this indicator.
  IndicatorConfig createIndicatorConfig();

  /// Creates the menu options widget for this indicator.
  Widget getIndicatorOptions();
}

/// Moving average indicator
class MAIndicatorItem extends IndicatorItem {
  MAIndicatorItem({
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
  _IndicatorItemState createIndicatorItemState() => MAIndicatorItemState();
}

class MAIndicatorItemState extends _IndicatorItemState<MAIndicatorConfig> {
  MovingAverageType _type;

  @override
  IndicatorConfig createIndicatorConfig() => MAIndicatorConfig(
        (List<Tick> ticks) => MASeries(ticks, period: 15, type: _type),
        period: 15,
        type: _type,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _type = _getCurrentType();
  }

  @override
  Widget getIndicatorOptions() => Row(
        children: [
          DropdownButton<MovingAverageType>(
            value: _getCurrentType(),
            items: MovingAverageType.values
                .map<DropdownMenuItem<MovingAverageType>>(
                    (MovingAverageType type) =>
                        DropdownMenuItem<MovingAverageType>(
                          value: type,
                          child: Text('${type.toString()}'),
                        ))
                .toList(),
            onChanged: (MovingAverageType newType) => setState(
              () {
                _type = newType;
                widget.onAddIndicator
                    ?.call(getIndicatorKey(), createIndicatorConfig());
              },
            ),
          )
        ],
      );

  MovingAverageType _getCurrentType() =>
      getConfig()?.type ?? MovingAverageType.simple;
}
