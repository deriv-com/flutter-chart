import 'dart:ui';

import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/components/chart/chart.dart';
import 'package:deriv_chart/src/components/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/chart_controller.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../callbacks.dart';
import 'indicators_ui/indicator_config.dart';
import 'indicators_ui/indicator_repository.dart';
import 'indicators_ui/indicators_dialog.dart';

/// A wrapper around the [Chart] which handles adding indicators to the chart.
class DerivChart extends StatefulWidget {
  /// Initializes
  const DerivChart({
    @required this.mainSeries,
    @required this.granularity,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.onVisibleAreaChanged,
    this.theme,
    this.isLive,
    this.dataFitEnabled = false,
    this.annotations,
    this.opacity = 1.0,
    this.pipSize = 4,
    Key key,
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

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  @override
  _DerivChartState createState() => _DerivChartState();
}

class _DerivChartState extends State<DerivChart> {
  final IndicatorsRepository _indicatorsRepo = IndicatorsRepository();

  @override
  void initState() {
    super.initState();
    loadSavedIndicators();
  }

  Future<void> loadSavedIndicators() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _indicatorsRepo.loadFromPrefs(prefs);
    } on Exception {
      // ignore: unawaited_futures
      showDialog<void>(
          context: context,
          builder: (BuildContext context) => AnimatedPopupDialog(
                child: Center(
                  child: Text(
                    ChartLocalization.of(context).warnFailedLoadingIndicators,
                  ),
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<IndicatorsRepository>.value(
        value: _indicatorsRepo,
        builder: (BuildContext context, Widget child) => Stack(
          children: <Widget>[
            Chart(
              mainSeries: widget.mainSeries,
              pipSize: widget.pipSize,
              granularity: widget.granularity,
              controller: widget.controller,
              overlaySeries: <Series>[
                ...context
                    .watch<IndicatorsRepository>()
                    .indicators
                    .where((IndicatorConfig indicatorConfig) =>
                        indicatorConfig != null && indicatorConfig.isOverlay)
                    .map((IndicatorConfig indicatorConfig) =>
                        indicatorConfig.getSeries(
                          IndicatorInput(
                            widget.mainSeries.input,
                            widget.granularity,
                          ),
                        ))
              ],
              bottomSeries: <Series>[
                ...context
                    .watch<IndicatorsRepository>()
                    .indicators
                    .where((IndicatorConfig indicatorConfig) =>
                        indicatorConfig != null && !indicatorConfig.isOverlay)
                    .map((IndicatorConfig indicatorConfig) =>
                        indicatorConfig.getSeries(
                          IndicatorInput(
                            widget.mainSeries.input,
                            widget.granularity,
                          ),
                        ))
              ],
              markerSeries: widget.markerSeries,
              theme: widget.theme,
              onCrosshairAppeared: widget.onCrosshairAppeared,
              onVisibleAreaChanged: widget.onVisibleAreaChanged,
              isLive: widget.isLive,
              dataFitEnabled: widget.dataFitEnabled,
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
                        ChangeNotifierProvider<IndicatorsRepository>.value(
                      value: _indicatorsRepo,
                      child: IndicatorsDialog(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      );
}
