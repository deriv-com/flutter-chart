import 'dart:collection';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_adapter/src/models/chart_data.dart';
import 'package:web_adapter/src/models/message.dart';

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

  /// Barriers for stop loss and take profit
  HorizontalBarrier? slBarrier, tpBarrier;

  /// Draggable barrier
  HorizontalBarrier? draggableBarrier;

  /// Shade Type
  ShadeType shadeType = ShadeType.none;

  bool _isDragging = false;

  late final ChartController _controller;

  late final ChartDataModel _chartDataModel;

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

  void _updateTPBarrier(dynamic barrier) {
    tpBarrier = HorizontalBarrier(
      barrier['high'],
      title: barrier['title'],
      style: const HorizontalBarrierStyle(
        isDashed: false,
      ),
    );
  }

  void _updateSLBarrier(dynamic barrier) {
    slBarrier = HorizontalBarrier(
      barrier['high'],
      title: barrier['title'],
      style: const HorizontalBarrierStyle(
        color: Color(0xFFCC2E3D),
        isDashed: false,
      ),
    );
  }

  void _updateShadeBarrier(dynamic barrier) {
    shadeType = _getShadeType(barrier['shade']);
  }

  ShadeType _getShadeType(String? shade) {
    switch (shade) {
      case 'BELOW':
        return ShadeType.below;
      case 'ABOVE':
        return ShadeType.above;
    }
    return ShadeType.none;
  }

  String _padCenter(String value, {int width = 10}) {
    if (value.length > width) {
      return value;
    }

    final int diff = width - value.length;
    return value.padLeft(value.length + (diff / 2).floor()).padRight(width);
  }

  String _getDragBarrierLabel(double value, bool isRelative) {
    final String barrierValue = value.toStringAsFixed(2);

    if (isRelative) {
      return value >= 0
          ? _padCenter('+$barrierValue')
          : _padCenter('-$barrierValue');
    } else {
      return _padCenter(barrierValue);
    }
  }

  void _onDrag(double newQuote, bool isReleased, dynamic barrier) {
    final bool isRelative = barrier['relative'];

    if (isReleased) {
      _isDragging = false;
      double high;

      if (isRelative) {
        high = newQuote - _chartDataModel.ticks.last.quote;
      } else {
        high = newQuote;
      }

      final Map<String, dynamic> barrierDragEvent = <String, dynamic>{
        'high': high.toStringAsFixed(2)
      };

      final Message loadHistoryMessage =
          Message('BARRIER_DRAG', jsonEncode(barrierDragEvent));

      html.window.parent!.postMessage(loadHistoryMessage.toJson(), '*');
    } else {
      final double label;
      _isDragging = true;

      if (isRelative) {
        label = newQuote - _chartDataModel.ticks.last.quote;
      } else {
        label = newQuote;
      }

      draggableBarrier = HorizontalBarrier(
        newQuote,
        label: _getDragBarrierLabel(label, isRelative),
        onDrag: (double newQuote, bool isReleased) =>
            _onDrag(newQuote, isReleased, barrier),
        style: const HorizontalBarrierStyle(
          isDashed: false,
          hasArrow: false,
          isDraggable: true,
          color: Color(0xFF999999),
        ),
      );
    }
    notifyListeners();
  }

  void _updateDraggableBarrier(dynamic barrier) {
    if (_chartDataModel.ticks.isEmpty) {
      return;
    }

    final double value = barrier['relative'] == true
        ? _chartDataModel.ticks.last.quote + barrier['high']
        : barrier['high'];

    draggableBarrier = HorizontalBarrier(
      value,
      label: _getDragBarrierLabel(barrier['high'], barrier['relative']),
      onDrag: (double newQuote, bool isReleased) =>
          _onDrag(newQuote, isReleased, barrier),
      style: HorizontalBarrierStyle(
        isDashed: false,
        hasArrow: false,
        isDraggable: true,
        color: const Color(0xFF999999),
        shadeType: _getShadeType(barrier['shade']),
      ),
    );
  }

  void _updateBarriers(List<dynamic> barriers) {
    _clearBarriers();

    for (final dynamic barrier in barriers) {
      String? key = barrier['key'];

      if (barrier['high'] == 0 &&
          (barrier['shade'] == 'BELOW' || barrier['shade'] == 'ABOVE')) {
        key = 'shade';
      } else if (barrier['draggable'] == true) {
        key = 'draggable';
      }

      switch (key) {
        case 'take_profit':
          _updateTPBarrier(barrier);
          break;
        case 'stop_loss':
          _updateSLBarrier(barrier);
          break;
        case 'stop_out':
          _updateSLBarrier(barrier);
          break;
        case 'shade':
          _updateShadeBarrier(barrier);
          break;
        case 'draggable':
          if (!_isDragging) {
            _updateDraggableBarrier(barrier);
          }
          break;
      }
    }

    notifyListeners();
  }

  void _clearBarriers() {
    tpBarrier = slBarrier = null;
    shadeType = ShadeType.none;

    if (!_isDragging) {
      draggableBarrier = null;
    }
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
