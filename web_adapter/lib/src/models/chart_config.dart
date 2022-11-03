import 'dart:collection';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// State and methods of chart web adapter config.
class ChartConfigModel extends ChangeNotifier {
  /// Initialize
  ChartConfigModel(this._controller);

  /// Style of the chart
  ChartStyle style = ChartStyle.line;

  /// Granularity
  int? granularity;

  /// Theme of the chart
  ChartTheme? theme;
  late final ChartController _controller;

  /// Updates the ChartConfigModel state
  void update(String messageType, dynamic payload) {
    switch (messageType) {
      case 'UPDATE_THEME':
        _updateTheme(payload);
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
    }
  }

  void _updateChartStyle(String payload) {
    style = payload == ChartStyle.candles.name
        ? ChartStyle.candles
        : ChartStyle.line;
    notifyListeners();
  }

  void _updateTheme(String payload) {
    theme =
        payload == 'dark' ? ChartDefaultDarkTheme() : ChartDefaultLightTheme();
    notifyListeners();
  }

  void _onNewChart(LinkedHashMap<dynamic, dynamic> payload) {
    if (payload['granularity'] != null) {
      final int _granularity = payload['granularity'];
      granularity = _granularity == 0 ? 1 * 1000 : _granularity * 1000;
      notifyListeners();
    }
  }

  void _onScale(double payload) {
    final double scale = payload;
    _controller.scale(scale);
  }
}
