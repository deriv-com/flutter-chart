import 'dart:async';
import 'dart:collection';

import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';

typedef OnMarketsStatusChange = void Function(List<ActiveSymbol> symbols);

/// A class to to remind us when there is change on opening and closing a market.
class TradingTimesReminder {
  /// Initializes
  TradingTimesReminder(this.tradingTimes, {this.onMarketsStatusChange}) {
    _fillTheQueue();
    _setReminderTimer();
  }

  /// Trading times
  final TradingTimes tradingTimes;

  /// Gets called when market status changes with the list of symbols that their
  /// open/closed status is changed.
  final OnMarketsStatusChange onMarketsStatusChange;

  Queue<DateTime> _statusChangeTimes = Queue<DateTime>();

  Timer _reminderTimer;

  void _fillTheQueue() {
    _statusChangeTimes
      ..addLast(DateTime.now().add(const Duration(seconds: 10)))
      ..addLast(DateTime.now().add(const Duration(seconds: 15)));
  }

  void _setReminderTimer() {
    _reminderTimer?.cancel();

    if (_statusChangeTimes.isNotEmpty) {
      final DateTime now = DateTime.now();
      final DateTime nextStatusChangeTime = _statusChangeTimes.removeFirst();

        _reminderTimer = Timer(
          nextStatusChangeTime.difference(now),
          () {
            onMarketsStatusChange?.call(null);

            // Next status change in the Queue.
            _setReminderTimer();
          },
        );
    }
  }
}
