import 'dart:convert' show json;
import 'dart:io' show WebSocket;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/base_api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/services/dependency_injector/injector.dart';
import 'package:flutter_deriv_api/services/dependency_injector/module_container.dart';
import 'package:vibration/vibration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FullscreenChart(),
      ),
    );
  }
}

class FullscreenChart extends StatefulWidget {
  const FullscreenChart({
    Key key,
  }) : super(key: key);

  @override
  _FullscreenChartState createState() => _FullscreenChartState();
}

class _FullscreenChartState extends State<FullscreenChart> {
  WebSocket ws;

  List<Candle> candles = [];
  ChartStyle style = ChartStyle.line;
  int granularity = 0;

  List<Market> _markets;
  Asset symbol = Asset(name: 'R_50', displayName: 'Volatility Index 50');

  @override
  void initState() {
    super.initState();
    _initTickStream();
    _getActiveSymbols();
  }

  Future<void> _getActiveSymbols() async {
    ModuleContainer().initialize(Injector.getInjector());
    await Injector.getInjector().get<BaseAPI>().connect(
          ConnectionInformation(
            appId: '1089',
            brand: 'binary',
            endpoint: 'frontend.binaryws.com',
          ),
        );

    final List<ActiveSymbol> activeSymbols =
        await ActiveSymbol.fetchActiveSymbols(const ActiveSymbolsRequest(
            activeSymbols: 'brief', productType: 'basic'));

    final List<String> marketTitles = [];

    _markets = List<Market>();

    for (final symbol in activeSymbols) {
      if (!marketTitles.contains(symbol.market)) {
        marketTitles.add(symbol.market);
        _markets.add(
          Market.fromSymbols(
            name: symbol.market,
            displayName: symbol.marketDisplayName,
            symbols: activeSymbols
                .where((activeSymbol) => activeSymbol.market == symbol.market)
                .map<Symbol>((activeSymbol) => Symbol(
                      market: activeSymbol.market,
                      submarket: activeSymbol.submarket,
                      symbol: activeSymbol.symbol,
                      displayName: activeSymbol.displayName,
                      submarketDisplayName: activeSymbol.submarketDisplayName,
                    ))
                .toList(),
          ),
        );
      }
    }
    setState(() {});
  }

  void _initTickStream() async {
    try {
      ws = await WebSocket.connect(
          'wss://ws.binaryws.com/websockets/v3?app_id=1089');

      if (ws?.readyState == WebSocket.open) {
        ws.listen(
          (response) {
            final data = Map<String, dynamic>.from(json.decode(response));

            if (data['history'] != null) {
              final history = <Candle>[];
              final count = data['history']['prices'].length;
              for (var i = 0; i < count; i++) {
                history.add(Candle.tick(
                  epoch: data['history']['times'][i] * 1000,
                  quote: data['history']['prices'][i].toDouble(),
                ));
              }
              setState(() {
                candles = history;
              });
            }

            if (data['candles'] != null) {
              setState(() {
                candles = data['candles'].map<Candle>((json) {
                  return Candle(
                    epoch: json['epoch'] * 1000,
                    high: json['high'].toDouble(),
                    low: json['low'].toDouble(),
                    open: json['open'].toDouble(),
                    close: json['close'].toDouble(),
                  );
                }).toList();
              });
            }

            if (data['tick'] != null) {
              final epoch = data['tick']['epoch'] * 1000;
              final quote = data['tick']['quote'].toDouble();
              _onNewTick(epoch, quote);
            }

            if (data['ohlc'] != null) {
              final newCandle = Candle(
                epoch: data['ohlc']['open_time'] * 1000,
                high: double.parse(data['ohlc']['high']),
                low: double.parse(data['ohlc']['low']),
                open: double.parse(data['ohlc']['open']),
                close: double.parse(data['ohlc']['close']),
              );
              _onNewCandle(newCandle);
            }
          },
          onDone: () => print('Done!'),
          onError: (e) => throw new Exception(e),
        );
        _requestData();
      }
    } catch (e) {
      ws?.close();
      print('Error: $e');
    }
  }

  void _requestData() {
    ws.add(json.encode({
      'ticks_history': symbol.name,
      'end': 'latest',
      'count': 1000,
      'style': granularity == 0 ? 'ticks' : 'candles',
      if (granularity > 0) 'granularity': granularity,
      'subscribe': 1,
    }));
  }

  void _onNewTick(int epoch, double quote) {
    setState(() {
      candles = candles + [Candle.tick(epoch: epoch, quote: quote)];
    });
  }

  void _onNewCandle(Candle newCandle) {
    final previousCandles =
        candles.isNotEmpty && candles.last.epoch == newCandle.epoch
            ? candles.sublist(0, candles.length - 1)
            : candles;

    setState(() {
      // Don't modify candles in place, othewise Chart's didUpdateWidget won't see the difference.
      candles = previousCandles + [newCandle];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF0E0E0E),
      child: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Chart(
              candles: candles,
              pipSize: 4,
              style: style,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildChartTypeButton(),
                    _buildIntervalSelector(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: _markets == null
                  ? SizedBox.shrink()
                  : _buildMarketSelectorButton(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarketSelectorButton(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: FlatButton(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FadeInImage(
                width: 32,
                height: 32,
                placeholder: AssetImage(
                  'assets/icons/icon_placeholder.png',
                  package: 'deriv_chart',
                ),
                image: AssetImage(
                  'assets/icons/${symbol.name}.png',
                  package: 'deriv_chart',
                ),
              ),
              SizedBox(width: 16),
              Text(
                symbol.displayName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          onPressed: () {
            showBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) => MarketSelector(
                markets: _markets,
                onAssetClicked: (asset, favoriteClicked) {
                  Navigator.of(context).pop();
                  symbol = asset;
                  _onIntervalSelected(granularity);
                },
              ),
            );
          },
        ),
      );

  IconButton _buildChartTypeButton() {
    return IconButton(
      icon: Icon(
        style == ChartStyle.line ? Icons.show_chart : Icons.insert_chart,
        color: Colors.white,
      ),
      onPressed: () {
        Vibration.vibrate(duration: 50);
        setState(() {
          if (style == ChartStyle.candles) {
            style = ChartStyle.line;
          } else {
            style = ChartStyle.candles;
          }
        });
      },
    );
  }

  Widget _buildIntervalSelector() {
    return Theme(
      data: ThemeData.dark(),
      child: DropdownButton<int>(
        value: granularity,
        items: <int>[
          0,
          60,
          120,
          180,
          300,
          600,
          900,
          1800,
          3600,
          7200,
          14400,
          28800,
          86400,
        ]
            .map<DropdownMenuItem<int>>((granularity) => DropdownMenuItem<int>(
                  value: granularity,
                  child: Text('${_granularityLabel(granularity)}'),
                ))
            .toList(),
        onChanged: _onIntervalSelected,
      ),
    );
  }

  void _onIntervalSelected(value) {
    ws.add(
      json.encode({'forget_all': granularity == 0 ? 'ticks' : 'candles'}),
    );
    setState(() {
      granularity = value;
    });
    _requestData();
  }

  String _granularityLabel(int granularity) {
    switch (granularity) {
      case 0:
        return '1 tick';
      case 60:
        return '1 min';
      case 120:
        return '2 min';
      case 180:
        return '3 min';
      case 300:
        return '5 min';
      case 600:
        return '10 min';
      case 900:
        return '15 min';
      case 1800:
        return '30 min';
      case 3600:
        return '1 hour';
      case 7200:
        return '2 hours';
      case 14400:
        return '4 hours';
      case 28800:
        return '8 hours';
      case 86400:
        return '1 day';
      default:
        return '???';
    }
  }
}
