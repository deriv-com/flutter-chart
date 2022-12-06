import 'dart:collection';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
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
  ChartTheme? theme;

  /// Markers
  List<MarkerGroup> markerGroupList = <MarkerGroup>[];

  /// Active marker
  ActiveMarker? activeMarker;

  /// Whether the chart should be showing live data or not.
  bool isLive = false;

  late final ChartController _controller;

  late final ChartDataModel _chartDataModel;

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

  Color _colorFromHex(String hexColor) =>
      Color(int.parse(hexColor.replaceAll('#', '0xff')));

  MarkerType _getMarkerType(String? _markerType) {
    switch (_markerType) {
      case 'START':
        return MarkerType.start;
      case 'ENTRY':
        return MarkerType.entry;
      case 'CURRENT':
        return MarkerType.current;
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

      for (final dynamic _marker in _markerGroup['markers']) {
        final bool isActiveMarker = _markerGroup == _markerGroupList.last &&
            _getMarkerType(_marker['type']) == MarkerType.start;

        markers.add(Marker(
          quote: _marker['quote'] ??
              _chartDataModel.getQuoteForEpoch(_marker['epoch']),
          epoch: _marker['epoch'],
          text: _marker['text'],
          markerType: isActiveMarker
              ? MarkerType.activeStart
              : _getMarkerType(_marker['type']),
          direction: MarkerDirection.up,
        ));
      }

      Color _bgColor = Colors.white;

      if (_markerGroup['color'] != null) {
        _bgColor = _colorFromHex(_markerGroup['color']);
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
      final int _granularity = payload['granularity'];
      granularity = _granularity == 0 ? 1 * 1000 : _granularity * 1000;
    }

    if (payload['isLive'] != null) {
      isLive = payload['isLive'];
    }
    notifyListeners();
  }

  void _onScale(double payload) {
    final double scale = payload;
    _controller.scale(scale);
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
