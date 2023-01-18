import 'dart:convert';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_adapter/src/interop/js_interop.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// State and methods of chart web adapter data.
class ChartDataModel extends ChangeNotifier {
  /// Tick data.
  List<Tick> ticks = <Tick>[];

  /// Flag to indicate the status of ticks network request.
  bool waitingForHistory = false;

  Tick _parseTick(JsQuote item) => Tick(
        epoch: DateTime.parse('${item.Date}Z').millisecondsSinceEpoch,
        quote: item.Close,
      );

  Candle _parseCandle(JsQuote item) => Candle(
        epoch: DateTime.parse('${item.Date}Z').millisecondsSinceEpoch,
        high: item.High!,
        low: item.Low!,
        open: item.Open!,
        close: item.Close,
      );

  /// Updates the chart with new tick
  void onNewTick(JsQuote quote) {
    final Tick tick = _parseTick(quote);
    ticks = ticks + <Tick>[tick];
    notifyListeners();
  }

  /// Updates the chart with new candle
  void onNewCandle(JsQuote quote) {
    final Candle newCandle = _parseCandle(quote);
    final List<Tick> previousCandles =
        ticks.isNotEmpty && ticks.last.epoch == newCandle.epoch
            ? ticks.sublist(0, ticks.length - 1)
            : ticks;

    // Don't modify candles in place, otherwise Chart's didUpdateWidget won't
    // see the difference.
    ticks = previousCandles + <Candle>[newCandle];
    notifyListeners();
  }

  /// To update the tick history
  // ignore: avoid_positional_boolean_parameters
  void onTickHistory(List<JsQuote> quotes, bool append) {
    if (quotes.isEmpty) {
      return;
    }

    List<Tick> newTicks = quotes
        .map((JsQuote item) =>
            item.Open != null ? _parseCandle(item) : _parseTick(item))
        .toList();

    if (quotes.first.Open != null) {
      newTicks = quotes.map((JsQuote item) => _parseCandle(item)).toList();
    } else {
      newTicks = quotes.map((JsQuote item) => _parseTick(item)).toList();
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

    JsInterop.loadHistory(JsLoadHistoryReq(
      count: count,
      end: ticks.first.epoch ~/ 1000,
    ));

    notifyListeners();
  }
}
