import 'dart:async';
import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:flutter_deriv_api/api/common/models/market_model.dart';
import 'package:flutter_deriv_api/api/common/models/submarket_model.dart';
import 'package:flutter_deriv_api/api/common/models/symbol_model.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';

/// Markets status change callback. (List of symbols that have been changed.)
typedef OnMarketsStatusChanged = Future<void> Function(
  Map<String, bool> symbols,
);

/// A class to remind when there is a change on market.
///
///
/// This class will notify about the status changes in market by calling
/// [onMarketsStatusChange] with a Map of {symbolCode: status}.
/// For example it might be like:
///
///   {'frxAUDJPY': false, 'frxUSDMXN': true}
///   Meaning that at this time frxAUDJPY will become closed and frxUSDMXN opens.
///
///
/// At start this class gets the TradingTimes and it will setup a queue of the upcoming
/// market changes and sets a timer to notify about the first one.
/// Once first timer finishes it will set for the next status change and so on,
/// until its queue becomes empty and will sets the last timer to the start of
/// tomorrow to reset its queue.
class MarketChangeReminder {
  /// Initializes a class to remind when there is a change on market.
  MarketChangeReminder(
    this.onTradingTimes, {
    this.onCurrentTime,
    this.onMarketsStatusChange,
  }) {
    _init();
  }

  static final DateFormat _dateFormat = DateFormat('hh:mm:ss');
  static final RegExp _timeFormatReg = RegExp(r'[0-9]{2}:[0-9]{2}:[0-9]{2}');

  /// Callback to get server time
  ///
  /// If not set, `DateTime.now().toUTC()` will be used.
  final Future<DateTime> Function() onCurrentTime;

  /// Callback to get trading times of today
  final Future<TradingTimes> Function() onTradingTimes;

  // TODO(Ramin): Consider using a reliable timer if Dart's version had any problems.
  Timer _reminderTimer;

  /// Gets called when market status changes with the list of symbols that their
  /// open/closed status is changed.
  final OnMarketsStatusChanged onMarketsStatusChange;

  /// List of upcoming market change times.
  ///
  /// [SplayTreeMap] has been used to have the change times in correct order
  /// while we are adding new entries to it.
  final SplayTreeMap<DateTime, Map<String, bool>> statusChangeTimes =
      SplayTreeMap<DateTime, Map<String, bool>>();

  Future<void> _init() async {
    await _fillStatusChangeMap();
    await _setReminderTimer();
  }

  Future<void> _fillStatusChangeMap() async {
    final DateTime now = await _getCurrentTime();
    final TradingTimes todayTradingTimes = await onTradingTimes();

    for (final MarketModel market in todayTradingTimes.markets) {
      for (final SubmarketModel subMarket in market.submarkets) {
        for (final SymbolModel symbol in subMarket.symbols) {
          final List<String> openTimes = symbol.times.open;
          final List<String> closeTimes = symbol.times.close;

          final bool isOpenAllDay = openTimes.length == 1 &&
              openTimes.first == '00:00:00' &&
              closeTimes.first == '23:59:59';
          final bool isClosedAllDay = openTimes.length == 1 &&
              openTimes.first == '--' &&
              closeTimes.first == '--';

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

    final DateTime hourMinSec = _dateFormat.parse(time);

    final DateTime statusChangeTime = DateTime.utc(
      now.year,
      now.month,
      now.day,
      hourMinSec.hour,
      hourMinSec.minute,
      hourMinSec.second,
    );

    if (now.isAfter(statusChangeTime) ||
        now.isAtSameMomentAs(statusChangeTime)) {
      return;
    }

    statusChangeTimes[statusChangeTime] ??= <String, bool>{};

    statusChangeTimes[statusChangeTime][symbol] = goesOpen;
  }

  /// Removes the next upcoming market change time from [statusChangeTimes] and sets a timer for it.
  Future<void> _setReminderTimer() async {
    _reminderTimer?.cancel();

    final DateTime now = await _getCurrentTime();

    if (statusChangeTimes.isNotEmpty) {
      final DateTime nextStatusChangeTime = statusChangeTimes.firstKey();
      final Map<String, bool> symbolsChanging =
          statusChangeTimes.remove(nextStatusChangeTime);

      _reminderTimer = Timer(
        // We add 5 seconds delay to be sure market status is actually changed.
        nextStatusChangeTime.add(const Duration(seconds: 5)).difference(now),
        () async {
          await onMarketsStatusChange?.call(symbolsChanging);

          // Reminder for the next status change in the Queue.
          await _setReminderTimer();
        },
      );
    } else {
      // Setting a timer to reset trading times when next day start.
      final DateTime tomorrowStart = DateTime(now.year, now.month, now.day + 1);
      _reminderTimer = Timer(tomorrowStart.difference(now), () => _init());
    }
  }

  Future<DateTime> _getCurrentTime() async =>
      onCurrentTime == null ? DateTime.now().toUtc() : await onCurrentTime();

  /// Cancels current reminder timer.
  void reset() => _reminderTimer?.cancel();
}
