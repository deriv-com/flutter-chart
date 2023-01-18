import 'dart:convert';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_adapter/src/helper.dart';
import 'package:web_adapter/src/interop/js_interop.dart';

/// State and methods of chart web adapter config.
class ChartConfigModel extends ChangeNotifier {
  /// Initialize
  ChartConfigModel(this._controller);

  /// Style of the chart
  ChartStyle style = ChartStyle.line;

  /// Granularity
  int? granularity;

  /// Theme of the chart
  ChartTheme theme = ChartDefaultLightTheme();

  /// Markers
  List<MarkerGroup> markerGroupList = <MarkerGroup>[];

  /// Active marker
  ActiveMarker? activeMarker;

  /// Whether the chart should be showing live data or not.
  bool isLive = false;

  /// Starts in data fit mode and adds a data-fit button.
  bool dataFitEnabled = false;

  /// Whether to use digit contract painter or non-digit contract painter
  bool isDigitContract = false;

  late final ChartController _controller;

  /// Indicators repo
  final AddOnsRepository<IndicatorConfig> indicatorsRepo =
      AddOnsRepository<IndicatorConfig>(IndicatorConfig);

  /// To update style of the chart
  // ignore: avoid_positional_boolean_parameters
  void updateLiveStatus(bool _isLive) {
    isLive = _isLive;
    notifyListeners();
  }

  /// To update style of the chart
  void updateChartStyle(String chartStyle) {
    style = chartStyle == ChartStyle.candles.name
        ? ChartStyle.candles
        : ChartStyle.line;
    notifyListeners();
  }

  /// Update markers
  void updateMarkers(List<JSMarkerGroupUpdate> _markerGroupList) {
    markerGroupList = <MarkerGroup>[];

    for (final JSMarkerGroupUpdate _markerGroup in _markerGroupList) {
      final List<Marker> markers = <Marker>[];

      isDigitContract = _markerGroup.type == 'DigitContract';

      for (final JsMarker _marker in _markerGroup.markers) {
        markers.add(Marker(
          quote: _marker.quote,
          epoch: _marker.epoch,
          text: _marker.text,
          markerType: MarkerType.values.byName(_marker.type),
          direction: MarkerDirection.up,
        ));
      }

      Color _bgColor = Colors.white;

      if (_markerGroup.color != null) {
        _bgColor = getColorFromHex(_markerGroup.color!);
      }

      markerGroupList.add(
        MarkerGroup(
          markers,
          style: MarkerStyle(
            backgroundColor: _bgColor,
          ),
        ),
      );
    }
  }

  /// To update the theme of the chart
  void updateTheme(String _theme) {
    theme =
        _theme == 'dark' ? ChartDefaultDarkTheme() : ChartDefaultLightTheme();
    notifyListeners();
  }

  /// Initialize new chart
  void newChart(JSNewChart payload) {
    granularity = payload.granularity;
    isLive = payload.isLive;
    dataFitEnabled = payload.dataFitEnabled;

    notifyListeners();
  }

  /// Scroll chart visible area to the newest data.
  void scale(double payload) {
    final double scale = payload;
    _controller.scale(scale);
  }

  /// To add or update an indicator
  void addOrUpdateIndicator(String dataString) {
    final Map<String, dynamic> config = json.decode(dataString);

    final int index = indicatorsRepo.addOns
        .indexWhere((IndicatorConfig addOn) => addOn.id == config['id']);

    final IndicatorConfig? indicatorConfig =
        IndicatorConfig.fromJson(config, 'name');

    if (indicatorConfig != null) {
      index > -1
          ? indicatorsRepo.updateAt(index, indicatorConfig)
          : indicatorsRepo.add(indicatorConfig);
    }
  }

  /// To remove an existing indicator
  void removeIndicator(String id) {
    final int index = indicatorsRepo.addOns
        .indexWhere((IndicatorConfig addOn) => addOn.id == id);
    indicatorsRepo.removeAt(index);
  }
}
