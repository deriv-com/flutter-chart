import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import 'message.dart';

class ChartConfigModel extends ChangeNotifier {
  ChartStyle style = ChartStyle.line;
  int? granularity;
  ChartTheme? theme;
  late final ChartController controller;

  ChartConfigModel(this.controller);

  void listen(Message message) {
    switch (message.type) {
      case 'UPDATE_THEME':
        _updateTheme(message);
        break;
      case 'NEW_CHART':
        _onNewChart(message);
        break;
      case 'SCALE_CHART':
        _onScale(message);
        break;
      case 'UPDATE_CHART_STYLE':
        _updateChartStyle(message);
        break;
    }
  }

  void _updateChartStyle(Message message) {
    style = message.payload == ChartStyle.candles.name
        ? ChartStyle.candles
        : ChartStyle.line;
    notifyListeners();
  }

  void _updateTheme(Message message) {
    theme = message.payload == 'dark'
        ? ChartDefaultDarkTheme()
        : ChartDefaultLightTheme();
    notifyListeners();
  }

  void _onNewChart(Message message) {
    print(message.payload['granularity']);
    if (message.payload['granularity'] != null) {
      int _granularity = message.payload['granularity'];
      granularity = _granularity == 0 ? 1 * 1000 : _granularity * 1000;
      notifyListeners();
    }
  }

  void _onScale(Message message) {
    double scale = message.payload;
    controller.scale(scale);
  }
}
