const String tradingTimesResponse = '''{
  "msg_type": "trading_times",
  "trading_times": {
    "markets": [
      {
        "name": "Stock Indices",
        "submarkets": [
          {
            "name": "Asia/Oceania",
            "symbols": [
              {
                "name": "Australian Index",
                "symbol": "OTC_AS51",
                "times": {
                  "open": [
                    "00:00:00",
                    "07:30:00"
                  ],
                  "close": [
                    "06:30:00",
                    "20:00:00"
                  ]
                }
              },
              {
                "name": "Hong Kong Index",
                "symbol": "OTC_HSI",
                "times": {
                  "open": [
                    "01:30:00",
                    "07:30:00"
                  ],
                  "close": [
                    "04:00:00",
                    "22:00:00"
                  ]
                }
              }
            ]
          }
        ]
      }
    ]
  }
}''';
