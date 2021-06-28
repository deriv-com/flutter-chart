import 'dart:convert';
import 'dart:async';

import 'package:example/utils/market_change_reminder.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';
import 'package:flutter_test/flutter_test.dart';

import 'trading_times_mock_data.dart';

void main() {
  group('Trading times', () {
    test('Trading times reminder queue fills in the correct order', () async {
      MarketChangeReminder tradingTimesReminder = MarketChangeReminder(
        () => Future<TradingTimes>.value(TradingTimes.fromJson(
          jsonDecode(tradingTimesResponse)['trading_times'],
        )),
        onCurrentTime: () =>
            Future<DateTime>.value(DateTime.utc(2020, 10, 10, 4, 0, 0)),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1));

      final firstMarketChangeDate =
          tradingTimesReminder.statusChangeTimes.firstKey();

      final firstMarkChangeSymbols =
          tradingTimesReminder.statusChangeTimes[firstMarketChangeDate!]!;

      // First date will be remove to set the first reminding timer
      expect(tradingTimesReminder.statusChangeTimes.length, 3);
      expect(firstMarketChangeDate, DateTime(2020, 10, 10, 7, 30));
      expect(firstMarkChangeSymbols.keys.first, 'OTC_AS51');
      expect(firstMarkChangeSymbols.values.first, true);

      final lastMarketChangeDate =
          tradingTimesReminder.statusChangeTimes.lastKey();

      final lastMarkChangeSymbols =
          tradingTimesReminder.statusChangeTimes[lastMarketChangeDate!]!;

      expect(lastMarketChangeDate, DateTime(2020, 10, 10, 22));
      expect(lastMarkChangeSymbols.keys.first, 'OTC_HSI');
      expect(lastMarkChangeSymbols.values.first, false);
    });
  });
}
