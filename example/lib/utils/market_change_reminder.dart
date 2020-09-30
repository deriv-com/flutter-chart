import 'dart:async';
import 'dart:collection';

import 'package:flutter_deriv_api/api/common/models/market_model.dart';
import 'package:flutter_deriv_api/api/common/models/submarket_model.dart';
import 'package:flutter_deriv_api/api/common/models/symbol_model.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';
import 'package:intl/intl.dart';

/// Markets status change callback. (List of symbols that have been changed.)
typedef OnMarketsStatusChange = void Function(Map<String, bool> symbols);

/// A class to to remind us when there is change on opening and closing a market.
class MarketChangeReminder {
  /// Initializes
  MarketChangeReminder(
    this.todayTradingTimes, {
    this.serverTime,
    this.onMarketsStatusChange,
  }) {
    _init();
  }

  static final DateFormat _dateFormat = DateFormat('hh:mm:ss');
  static final RegExp _timeFormatReg = RegExp(r'[0-9]{2}:[0-9]{2}:[0-9]{2}');

  /// Trading times
  final TradingTimes todayTradingTimes;

  /// Callback to get server time
  final Future<DateTime> Function() serverTime;

  // TODO(Ramin): Consider using a reliable timer if Dart's version had any problems.
  Timer _reminderTimer;

  /// Gets called when market status changes with the list of symbols that their
  /// open/closed status is changed.
  final OnMarketsStatusChange onMarketsStatusChange;

  /// List of upcoming market change times.
  ///
  /// [SplayTreeMap] has been used to have the change times in correct order
  /// while we are adding new entries to it.
  final SplayTreeMap<DateTime, Map<String, bool>> statusChangeTimes =
      SplayTreeMap<DateTime, Map<String, bool>>();

  Future<void> _init() async {
    await _fillTheQueue();
    await _setReminderTimer();
  }

  Future<void> _fillTheQueue() async {
    final DateTime now = await serverTime();

    for (final MarketModel market in todayTradingTimes.markets) {
      for (final SubmarketModel subMarket in market.submarkets) {
        for (final SymbolModel symbol in subMarket.symbols) {
          final List<dynamic> openTimes = symbol.times.open;
          final List<dynamic> closeTimes = symbol.times.close;

          final bool isOpenAllDay = openTimes.length == 1 &&
              openTimes[0] == '00:00:00' &&
              closeTimes[0] == '23:59:59';
          final bool isClosedAllDay = openTimes.length == 1 &&
              closeTimes[0] == '--' &&
              closeTimes[0] == '--';

          if (isOpenAllDay || isClosedAllDay) {
            continue;
          }

          for (final String time in openTimes) {
            _addEntryToStatusChanges(time, symbol.symbol, true, now);
          }

          for (final String time in closeTimes) {
            _addEntryToStatusChanges(time, symbol.symbol, false, now);
          }
        }
      }
    }
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

    statusChangeTimes[dateTime] ??= <String, bool>{};

    statusChangeTimes[dateTime][symbol] = goesOpen;
  }

  /// Removes the next upcoming market change time from [statusChangeTimes] and
  /// sets a timer for it.
  Future<void> _setReminderTimer() async {
    _reminderTimer?.cancel();

    if (statusChangeTimes.isNotEmpty) {
      final DateTime now = await serverTime();
      final DateTime nextStatusChangeTime = statusChangeTimes.firstKey();
      final Map<String, bool> symbolsChanging =
          statusChangeTimes.remove(nextStatusChangeTime);

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

  /// Cancels current reminder timer.
  void reset() => _reminderTimer?.cancel();
}
