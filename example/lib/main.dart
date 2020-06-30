import 'dart:convert' show json;
import 'dart:io' show WebSocket;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_flutter_chart/deriv_flutter_chart.dart';
import 'package:vibration/vibration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FullscreenChart(),
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

  @override
  void initState() {
    super.initState();
    _initTickStream();
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
      'ticks_history': 'R_50',
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
            _buildChartTypeButton(),
            Positioned(
              left: 60,
              child: _buildIntervalSelector(),
            )
          ],
        ),
      ),
    );
  }

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
