import 'dart:convert';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'message.dart';

/// State and methods of chart web adapter data.
class ChartDataModel extends ChangeNotifier {
  /// Tick data.
  List<Tick> ticks = <Tick>[];

  /// Flag to indicate the status of ticks network request.
  bool waitingForHistory = false;

  /// Updates the ChartConfigModel state
  void update(String messageType, dynamic payload) {
    switch (messageType) {
      case 'TICKS_HISTORY':
        _onTickHistory(payload, false);
        break;
      case 'PREPEND_TICKS_HISTORY':
        _onTickHistory(payload, true);
        break;
      case 'TICK':
        final Tick tick = _parseTick(payload);
        _onNewTick(tick);
        break;
      case 'CANDLE':
        final Candle candle = _parseCandle(payload);
        _onNewCandle(candle);
        break;
      case 'CLEAR_TICKS':
        _onClearTicks();
        break;
    }
  }

  Tick _parseTick(dynamic item) => Tick(
        epoch: DateTime.parse('${item['Date']}Z').millisecondsSinceEpoch,
        quote: item['Close'],
      );

  Candle _parseCandle(dynamic item) => Candle(
      epoch: DateTime.parse('${item['Date']}Z').millisecondsSinceEpoch,
      high: item['High'],
      low: item['Low'],
      open: item['Open'],
      close: item['Close']);

  void _onNewTick(Tick tick) {
    ticks = ticks + <Tick>[tick];
    notifyListeners();
  }

  void _onNewCandle(Candle newCandle) {
    final List<Tick> previousCandles =
        ticks.isNotEmpty && ticks.last.epoch == newCandle.epoch
            ? ticks.sublist(0, ticks.length - 1)
            : ticks;

    // Don't modify candles in place, otherwise Chart's didUpdateWidget won't
    // see the difference.
    ticks = previousCandles + <Candle>[newCandle];
    notifyListeners();
  }

  void _onTickHistory(List<dynamic> payload, bool append) {
    List<Tick> newTicks = payload
        .map((dynamic item) =>
            item['Open'] != null ? _parseCandle(item) : _parseTick(item))
        .toList();

    if (payload.first['Open'] != null) {
      newTicks = payload.map((dynamic item) => _parseCandle(item)).toList();
    } else {
      newTicks = payload.map((dynamic item) => _parseTick(item)).toList();
    }

    if (append) {
      while (newTicks.isNotEmpty && newTicks.last.epoch >= ticks.first.epoch) {
        newTicks.removeLast();
      }

      ticks.insertAll(0, newTicks);
    } else {
      ticks = newTicks;
    }

    if (append) {
      waitingForHistory = false;
    }

    notifyListeners();
  }

  void _onClearTicks() {
    ticks = <Tick>[];
    notifyListeners();
  }

  /// Loads old chart history
  void loadHistory(int count) {
    waitingForHistory = true;

    final Map<String, int> loadHistoryRequest = <String, int>{
      'count': count,
      'end': ticks.first.epoch ~/ 1000
    };

    final Message loadHistoryMessage =
        Message('LOAD_HISTORY', jsonEncode(loadHistoryRequest));

    html.window.parent!.postMessage(loadHistoryMessage.toJson(), '*');
    notifyListeners();
  }
}
