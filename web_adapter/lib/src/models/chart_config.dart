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

  /// Barriers for stop loss and take profit
  HorizontalBarrier? slBarrier, tpBarrier;

  /// Shade Type
  ShadeType shadeType = ShadeType.none;

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
      case 'UPDATE_BARRIERS':
        _updateBarriers(payload);
        break;
    }
  }

  void _updateChartStyle(String payload) {
    style = payload == ChartStyle.candles.name
        ? ChartStyle.candles
        : ChartStyle.line;
    notifyListeners();
  }

  void _updateRiskManagementBarries(List<dynamic> barriers) {
    final dynamic _stopLossBarrier = barriers.firstWhere(
      (dynamic barrier) => barrier['key'] == 'stop_loss',
      orElse: () => null,
    );

    final dynamic _stopOutBarrier = barriers.firstWhere(
      (dynamic barrier) => barrier['key'] == 'stop_out',
      orElse: () => null,
    );

    final dynamic _takeProfitBarrier = barriers.firstWhere(
      (dynamic barrier) => barrier['key'] == 'take_profit',
      orElse: () => null,
    );

    final dynamic _stopBarrier =
        _stopLossBarrier != null ? _stopLossBarrier : _stopOutBarrier;

    slBarrier = _stopBarrier != null
        ? HorizontalBarrier(
            _stopBarrier['high'],
            title: _stopBarrier['title'],
            style: const HorizontalBarrierStyle(
              color: Color(0xFFCC2E3D),
              isDashed: false,
            ),
          )
        : null;

    tpBarrier = _takeProfitBarrier != null
        ? HorizontalBarrier(
            _takeProfitBarrier['high'],
            title: _takeProfitBarrier['title'],
            style: const HorizontalBarrierStyle(
              isDashed: false,
            ),
          )
        : null;
  }

  void _updateBarriers(List<dynamic> barriers) {
    _updateRiskManagementBarries(barriers);

    final dynamic _shadeBarrier = barriers.firstWhere(
      (dynamic barrier) =>
          barrier['shade'] == 'BELOW' || barrier['shade'] == 'ABOVE',
      orElse: () => null,
    );

    if (_shadeBarrier != null) {
      shadeType =
          _shadeBarrier['shade'] == 'BELOW' ? ShadeType.below : ShadeType.above;
    } else {
      shadeType = ShadeType.none;
    }

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
