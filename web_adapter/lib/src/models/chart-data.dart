import 'dart:convert';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'message.dart';

class ChartDataModel extends ChangeNotifier {
  List<Tick> ticks = <Tick>[];
  bool waitingForHistory = false;

  void listen(Message message) {
    switch (message.type) {
      case 'TICKS_HISTORY':
        _onTickHistory(message, false);
        break;
      case 'PREPEND_TICKS_HISTORY':
        _onTickHistory(message, true);
        break;
      case 'TICK':
        Tick tick = _parseTick(message.payload);
        _onNewTick(tick);
        break;
      case 'CANDLE':
        Candle candle = _parseCandle(message.payload);
        _onNewCandle(candle);
        break;
      case 'CLEAR_TICKS':
        _onClearTicks();
        break;
    }
  }

  Tick _parseTick(dynamic item) {
    return Tick(
      epoch: DateTime.parse('${item['Date']}Z').millisecondsSinceEpoch,
      quote: item['Close'],
    );
  }

  Candle _parseCandle(dynamic item) {
    return Candle(
        epoch: DateTime.parse('${item['Date']}Z').millisecondsSinceEpoch,
        high: item['High'],
        low: item['Low'],
        open: item['Open'],
        close: item['Close']);
  }

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

  void _onTickHistory(Message message, bool append) {
    var payload = message.payload as List;

    var newTicks = payload.map((item) {
      return item['Open'] != null ? _parseCandle(item) : _parseTick(item);
    }).toList();

    if (payload.first['Open'] != null) {
      newTicks = payload.map((item) {
        return _parseCandle(item);
      }).toList();
    } else {
      newTicks = payload.map((item) {
        return _parseTick(item);
      }).toList();
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
    ticks = [];
    notifyListeners();
  }

  void loadHistory(int count) async {
    waitingForHistory = true;

    Map loadHistoryRequest = {"count": count, "end": ticks.first.epoch ~/ 1000};

    var loadHistoryMessage =
        Message('LOAD_HISTORY', jsonEncode(loadHistoryRequest));

    html.window.parent!.postMessage(loadHistoryMessage.toJson(), '*');
    notifyListeners();
  }
}
