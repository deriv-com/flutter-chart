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
  List<Candle> candles = [];
  ChartStyle style = ChartStyle.candles;

  @override
  void initState() {
    super.initState();
    _initTickStream();
  }

  void _initTickStream() async {
    WebSocket ws;
    try {
      ws = await WebSocket.connect(
          'wss://ws.binaryws.com/websockets/v3?app_id=1089');

      if (ws?.readyState == WebSocket.open) {
        ws.listen(
          (response) {
            final data = Map<String, dynamic>.from(json.decode(response));

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
        ws.add(json.encode({
          'ticks_history': 'R_50',
          'end': 'latest',
          'count': 1000,
          'style': 'candles',
          'granularity': 60,
          'subscribe': 1,
        }));
      }
    } catch (e) {
      ws?.close();
      print('Error: $e');
    }
  }

  void _onNewTick(int epoch, double quote) {
    setState(() {
      candles = candles + [Candle.tick(epoch: epoch, quote: quote)];
    });
  }

  void _onNewCandle(Candle newCandle) {
    if (candles.isEmpty || candles.last.epoch != newCandle.epoch) {
      setState(() {
        candles = candles + [newCandle];
      });
    } else {
      final excludeLast = candles.take(candles.length - 1).toList();
      final updatedLast = candles.last.copyWith(
        high: newCandle.high,
        low: newCandle.low,
        close: newCandle.close,
      );
      setState(() {
        candles = excludeLast + [updatedLast];
      });
    }
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
            IconButton(
              icon: Icon(
                style == ChartStyle.line
                    ? Icons.show_chart
                    : Icons.insert_chart,
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
            )
          ],
        ),
      ),
    );
  }
}
