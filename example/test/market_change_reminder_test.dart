import 'dart:async';
import 'dart:convert';

import 'package:example/utils/market_change_reminder.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';
import 'package:flutter_test/flutter_test.dart';

import 'trading_times_mock_data.dart';

void main() {
  group('Trading times', () {
    test('Trading times reminder queue fills in the correct order', () async {
      final MarketChangeReminder tradingTimesReminder = MarketChangeReminder(
        () => Future<TradingTimes>.value(TradingTimes.fromJson(
          jsonDecode(tradingTimesResponse)['trading_times'],
        )),
        onCurrentTime: () =>
            Future<DateTime>.value(DateTime.utc(2020, 10, 10, 4)),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1));

      final DateTime firstMarketChangeDate =
          tradingTimesReminder.statusChangeTimes.firstKey();

      final Map<String, bool> firstMarkChangeSymbols =
          tradingTimesReminder.statusChangeTimes[firstMarketChangeDate];

      // First date will be remove to set the first reminding timer
      expect(tradingTimesReminder.statusChangeTimes.length, 3);
      expect(firstMarketChangeDate, DateTime(2020, 10, 10, 7, 30));
      expect(firstMarkChangeSymbols.keys.first, 'OTC_AS51');
      expect(firstMarkChangeSymbols.values.first, true);

      final DateTime lastMarketChangeDate =
          tradingTimesReminder.statusChangeTimes.lastKey();

      final Map<String, bool> lastMarkChangeSymbols =
          tradingTimesReminder.statusChangeTimes[lastMarketChangeDate];

      expect(lastMarketChangeDate, DateTime(2020, 10, 10, 22));
      expect(lastMarkChangeSymbols.keys.first, 'OTC_HSI');
      expect(lastMarkChangeSymbols.values.first, false);
    });
  });
}
