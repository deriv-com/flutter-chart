import 'dart:convert' show json;
import 'dart:io' show WebSocket;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_flutter_chart/deriv_flutter_chart.dart';

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
  List<Tick> ticks = [];

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
            final epoch = data['tick']['epoch'] * 1000;
            final quote = data['tick']['quote'];
            _onNewTick(epoch, quote.toDouble());
          },
          onDone: () => print('Done!'),
          onError: (e) => throw new Exception(e),
        );
        ws.add(json.encode({'ticks': 'R_50'}));
      }
    } catch (e) {
      ws?.close();
      print('Error: $e');
    }
  }

  void _onNewTick(int epoch, double quote) {
    setState(() {
      ticks = ticks + [Tick(epoch: epoch, quote: quote)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF0E0E0E),
      child: SizedBox.expand(
        child: DerivFlutterChart(
          data: ticks,
        ),
      ),
    );
  }
}
