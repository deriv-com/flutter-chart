import 'dart:collection';
import 'dart:convert';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_adapter/src/helper.dart';
import 'package:web_adapter/src/interop/indicators_ui/js_indicator_config.dart';
import 'package:web_adapter/src/models/chart_data.dart';

/// State and methods of chart web adapter config.
class ChartConfigModel extends ChangeNotifier {
  /// Initialize
  ChartConfigModel(this._controller, this._chartDataModel);

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

  late final ChartDataModel _chartDataModel;

  /// Indicators repo
  final AddOnsRepository<IndicatorConfig> indicatorsRepo =
      AddOnsRepository<IndicatorConfig>(IndicatorConfig);

  /// Updates the ChartConfigModel state
  void update(String messageType, dynamic payload) {
    switch (messageType) {
      case 'UPDATE_THEME':
        updateTheme(payload);
        break;
      case 'NEW_CHART':
        _onNewChart(payload);
        break;
      case 'SCALE_CHART':
        _onScale(payload);
        break;
      case 'UPDATE_CHART_STYLE':
        _updateChartStyle(payload);
        break;
      case 'UPDATE_MARKERS':
        _updateMarkers(payload);
        break;
      case 'UPDATE_LIVE_STATUS':
        _updateLiveStatus(payload);
        break;
    }
  }

  void _updateLiveStatus(bool payload) {
    isLive = payload;
    notifyListeners();
  }

  void _updateChartStyle(String payload) {
    style = payload == ChartStyle.candles.name
        ? ChartStyle.candles
        : ChartStyle.line;
    notifyListeners();
  }

  MarkerType _getMarkerType(String? _markerType) {
    switch (_markerType) {
      case 'ACTIVE_START':
        return MarkerType.activeStart;
      case 'START':
        return MarkerType.start;
      case 'ENTRY':
        return MarkerType.entry;
      case 'LATEST_TICK':
        return MarkerType.latestTick;
      case 'TICK':
        return MarkerType.tick;
      case 'EXIT':
        return MarkerType.exit;
      case 'END':
        return MarkerType.end;
    }
    return MarkerType.start;
  }

  void _updateMarkers(List<dynamic> _markerGroupList) {
    markerGroupList = <MarkerGroup>[];

    for (final dynamic _markerGroup in _markerGroupList) {
      final List<Marker> markers = <Marker>[];

      isDigitContract = _markerGroup['type'] == 'DigitContract';

      for (final dynamic _marker in _markerGroup['markers']) {
        markers.add(Marker(
          quote: _marker['quote'],
          epoch: _marker['epoch'],
          text: _marker['text'],
          markerType: _getMarkerType(_marker['type']),
          direction: MarkerDirection.up,
        ));
      }

      Color _bgColor = Colors.white;

      if (_markerGroup['color'] != null) {
        _bgColor = getColorFromHex(_markerGroup['color']);
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

  void _onNewChart(LinkedHashMap<dynamic, dynamic> payload) {
    if (payload['granularity'] != null) {
      granularity = payload['granularity'];
    }

    if (payload['isLive'] != null) {
      isLive = payload['isLive'];
    }
    if (payload['dataFitEnabled'] != null) {
      dataFitEnabled = payload['dataFitEnabled'];
    }
    notifyListeners();
  }

  void _onScale(double payload) {
    final double scale = payload;
    _controller.scale(scale);
  }

  /// Gets the tooltip content for indicator series
  String getIndicatorTootipContent(int epoch) {
    // final IndicatorConfig config = indicatorsRepo.addOns.elementAt(0);
    // final AbstractSingleIndicatorSeries series = config
    //         .getSeries(IndicatorInput(_chartDataModel.ticks, granularity ?? 1))
    //     as AbstractSingleIndicatorSeries;

    // series.initialize();

    // print(series.entries?.last.epoch);

    // final Tick? item = series.entries?.firstWhere((Tick t) => t.epoch == epoch);

    // if (item != null) {
    //   print(item.close);
    // }

    return '';
  }

  /// To add or update an indicator
  void addOrUpdateIndicator(String dataString) {
    final Map<String, dynamic> config = json.decode(dataString);

    final int index = indicatorsRepo.addOns
        .indexWhere((IndicatorConfig addOn) => addOn.id == config['id']);

    final IndicatorConfig? indicatorConfig = getIndicatorConfig(config);

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

  /// Gets X position from epoch
  double? getXFromEpoch(int epoch) {
    if (_controller.getXFromEpoch != null) {
      return _controller.getXFromEpoch!(epoch);
    }
    return null;
  }

  /// Gets Y position from quote
  double? getYFromQuote(double quote) {
    if (_controller.getYFromQuote != null) {
      return _controller.getYFromQuote!(quote);
    }
    return null;
  }

  /// Gets epoch from x position
  int? getEpochFromX(double x) {
    if (_controller.getEpochFromX != null) {
      return _controller.getEpochFromX!(x);
    }
    return null;
  }

  /// Gets quote from y position
  double? getQuoteFromY(double y) {
    if (_controller.getQuoteFromY != null) {
      return _controller.getQuoteFromY!(y);
    }
    return null;
  }
}
