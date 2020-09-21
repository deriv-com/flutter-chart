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
    _prepareQueue();
    _setReminderTimer();
  }

  static DateFormat dateFormat = DateFormat('hh:mm:ss');

  /// Trading times
  final TradingTimes tradingTimes;

  /// Gets called when market status changes with the list of symbols that their
  /// open/closed status is changed.
  final OnMarketsStatusChange onMarketsStatusChange;

  SplayTreeMap<DateTime, List<SymbolStatusChange>> _statusChangeTimes =
      SplayTreeMap<DateTime, List<SymbolStatusChange>>(
          (DateTime d1, DateTime d2) => d1.compareTo(d2));

  Timer _reminderTimer;

  void _fillTheQueue() {
    tradingTimes.markets.forEach((MarketModel market) {
      market.submarkets.forEach((SubmarketModel subMarket) {
        subMarket.symbols.forEach((SymbolModel symbol) {
          final DateTime now = DateTime.now().toUtc();
          symbol.times.open.forEach((String openTime) {
            if (openTime == '--') return;

            final DateTime openDateTime = dateFormat.parse(openTime);

            _getValueOfKey(DateTime(
                    now.year,
                    now.month,
                    now.day,
                    openDateTime.hour,
                    openDateTime.minute,
                    openDateTime.second))
                .add(SymbolStatusChange(
              symbol.name,
              true,
            ));
          });

          symbol.times.close.forEach((String closeTime) {
            if (closeTime == '--') return;
            final DateTime closeDateTime = dateFormat.parse(closeTime);

            _getValueOfKey(DateTime(
                    now.year,
                    now.month,
                    now.day,
                    closeDateTime.hour,
                    closeDateTime.minute,
                    closeDateTime.second))
                .add(SymbolStatusChange(
              symbol.name,
              false,
            ));
          });
        });
      });
    });

    _statusChangeTimes.forEach((key, value) {
      print('');
    });

    print('object');
  }

  // Removing times that are passed
  void _prepareQueue() {
    final DateTime now = DateTime.now().toUtc();
    while (_statusChangeTimes.isNotEmpty) {

    }
  }

  List<SymbolStatusChange> _getValueOfKey(DateTime key) {
    _statusChangeTimes[key] ??= <SymbolStatusChange>[];

    return _statusChangeTimes[key];
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

          // Next status change in the Queue.
          _setReminderTimer();
        },
      );
    }
  }
}

/// Model class containing symbols status change information.
class SymbolStatusChange {
  /// Initializes
  SymbolStatusChange(this.symbol, this.goesOpen);

  /// The symbol
  final String symbol;

  /// If true [symbol] opens at [time]
  /// If false it closes at [time]
  final bool goesOpen;
}
