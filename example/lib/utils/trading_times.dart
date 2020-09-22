import 'dart:async';
import 'dart:collection';

import 'package:flutter_deriv_api/api/common/models/market_model.dart';
import 'package:flutter_deriv_api/api/common/models/submarket_model.dart';
import 'package:flutter_deriv_api/api/common/models/symbol_model.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';
import 'package:intl/intl.dart';

typedef OnMarketsStatusChange = void Function(List<SymbolStatusChange> symbols);

/// A class to to remind us when there is change on opening and closing a market.
class TradingTimesReminder {
  /// Initializes
  TradingTimesReminder(this.tradingTimes, {this.onMarketsStatusChange}) {
    _fillTheQueue();
    _setReminderTimer();
  }

  static DateFormat _dateFormat = DateFormat('hh:mm:ss');
  static RegExp _timeFormatReg = RegExp(r'[0-9]{2}:[0-9]{2}:[0-9]{2}');

  /// Trading times
  final TradingTimes tradingTimes;

  Timer _reminderTimer;

  /// Gets called when market status changes with the list of symbols that their
  /// open/closed status is changed.
  final OnMarketsStatusChange onMarketsStatusChange;

  SplayTreeMap<DateTime, List<SymbolStatusChange>> _statusChangeTimes =
      SplayTreeMap<DateTime, List<SymbolStatusChange>>(
          (DateTime d1, DateTime d2) => d1.compareTo(d2));

  void _fillTheQueue() {
    final DateTime now = DateTime.now().toUtc();

    tradingTimes.markets.forEach((MarketModel market) {
      market.submarkets.forEach((SubmarketModel subMarket) {
        subMarket.symbols.forEach((SymbolModel symbol) {
          symbol.times.open.forEach((String openTime) =>
              _addEntryToStatusChanges(openTime, symbol.symbol, true, now));

          symbol.times.close.forEach((String closeTime) =>
              _addEntryToStatusChanges(closeTime, symbol.symbol, false, now));
        });
      });
    });
  }

  void _addEntryToStatusChanges(
    String time,
    String symbol,
    bool goesOpen,
    DateTime now,
  ) {
    if (_timeFormatReg.allMatches(time).length != 1) {
      return;
    }

    final DateTime dateTimeOfToday = _dateFormat.parse(time);
    final DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      dateTimeOfToday.hour,
      dateTimeOfToday.minute,
      dateTimeOfToday.second,
    );

    if (now.compareTo(dateTime) >= 0) {
      return;
    }

    _statusChangeTimes[dateTime] ??= <SymbolStatusChange>[];

    _statusChangeTimes[dateTime].add(SymbolStatusChange(
      symbol,
      false,
    ));
  }

  void _setReminderTimer() {
    _reminderTimer?.cancel();

    if (_statusChangeTimes.isNotEmpty) {
      final DateTime now = DateTime.now().toUtc();
      final DateTime nextStatusChangeTime = _statusChangeTimes.firstKey();
      final List<SymbolStatusChange> symbolsChanging =
          _statusChangeTimes.remove(nextStatusChangeTime);

      _reminderTimer = Timer(
        nextStatusChangeTime.difference(now),
        () {
          onMarketsStatusChange?.call(symbolsChanging);

          // Reminder for the next status change in the Queue.
          _setReminderTimer();
        },
      );
    }
  }
}

/// Model class containing symbols status change information,
/// whether the [symbol] goes open/close at a specific time.
class SymbolStatusChange {
  /// Initializes
  SymbolStatusChange(this.symbol, this.goesOpen);

  /// The symbol
  final String symbol;

  /// If true [symbol] opens at [time]
  /// If false it closes at [time]
  final bool goesOpen;
}
