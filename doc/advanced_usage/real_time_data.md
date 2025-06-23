# Real-time Data

This document explains how to handle real-time data updates in the Deriv Chart library, enabling you to create dynamic charts that update as new market data arrives.

## Introduction

Financial charts often need to display real-time data, such as live market prices or streaming data feeds. The Deriv Chart library provides several mechanisms to efficiently handle real-time data updates without sacrificing performance.

## Basic Real-time Updates

### Updating the Data Series

The simplest way to handle real-time data is to update the data series when new data arrives:

```dart
class RealTimeChartExample extends StatefulWidget {
  @override
  State<RealTimeChartExample> createState() => _RealTimeChartExampleState();
}

class _RealTimeChartExampleState extends State<RealTimeChartExample> {
  List<Tick> _ticks = [];
  late StreamSubscription<Tick> _subscription;
  
  @override
  void initState() {
    super.initState();
    
    // Subscribe to a data stream
    _subscription = tickDataStream.listen((tick) {
      setState(() {
        _ticks.add(tick);
        
        // Optional: Limit the number of ticks to prevent memory issues
        if (_ticks.length > 1000) {
          _ticks = _ticks.sublist(_ticks.length - 1000);
        }
      });
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(_ticks),
      pipSize: 2,
    );
  }
}
```

### Auto-scrolling to Latest Data

To ensure the chart automatically scrolls to show the latest data:

```dart
class AutoScrollingChartExample extends StatefulWidget {
  @override
  State<AutoScrollingChartExample> createState() => _AutoScrollingChartExampleState();
}

class _AutoScrollingChartExampleState extends State<AutoScrollingChartExample> {
  List<Tick> _ticks = [];
  late StreamSubscription<Tick> _subscription;
  final _chartController = ChartController();
  bool _autoScroll = true;
  
  @override
  void initState() {
    super.initState();
    
    // Subscribe to a data stream
    _subscription = tickDataStream.listen((tick) {
      setState(() {
        _ticks.add(tick);
        
        // Optional: Limit the number of ticks to prevent memory issues
        if (_ticks.length > 1000) {
          _ticks = _ticks.sublist(_ticks.length - 1000);
        }
        
        // Auto-scroll to the latest tick if enabled
        if (_autoScroll) {
          _chartController.scrollToLastTick();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Auto-scroll'),
            Switch(
              value: _autoScroll,
              onChanged: (value) {
                setState(() {
                  _autoScroll = value;
                  
                  // If auto-scroll is re-enabled, scroll to the latest tick
                  if (_autoScroll) {
                    _chartController.scrollToLastTick();
                  }
                });
              },
            ),
          ],
        ),
        Expanded(
          child: Chart(
            mainSeries: LineSeries(_ticks),
            pipSize: 2,
            controller: _chartController,
            onVisibleAreaChanged: (leftEpoch, rightEpoch) {
              // Disable auto-scroll if the user manually scrolls away from the latest data
              if (_autoScroll && _ticks.isNotEmpty) {
                final latestEpoch = _ticks.last.epoch.millisecondsSinceEpoch;
                final rightEdgeTime = DateTime.fromMillisecondsSinceEpoch(rightEpoch);
                
                // If the latest tick is not visible, disable auto-scroll
                if (latestEpoch > rightEpoch) {
                  setState(() {
                    _autoScroll = false;
                  });
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
```

## Handling Different Data Types

### Real-time Tick Data

For streaming tick data (time-price pairs):

```dart
class RealTimeTickChartExample extends StatefulWidget {
  @override
  State<RealTimeTickChartExample> createState() => _RealTimeTickChartExampleState();
}

class _RealTimeTickChartExampleState extends State<RealTimeTickChartExample> {
  List<Tick> _ticks = [];
  late StreamSubscription<TickData> _subscription;
  final _chartController = ChartController();
  
  @override
  void initState() {
    super.initState();
    
    // Subscribe to a tick data stream
    _subscription = tickDataStream.listen((tickData) {
      setState(() {
        _ticks.add(Tick(
          epoch: DateTime.fromMillisecondsSinceEpoch(tickData.timestamp),
          quote: tickData.price,
        ));
        
        _chartController.scrollToLastTick();
      });
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(_ticks),
      pipSize: 2,
      controller: _chartController,
    );
  }
}
```

### Real-time OHLC Data

For streaming OHLC (candle) data:

```dart
class RealTimeCandleChartExample extends StatefulWidget {
  @override
  State<RealTimeCandleChartExample> createState() => _RealTimeCandleChartExampleState();
}

class _RealTimeCandleChartExampleState extends State<RealTimeCandleChartExample> {
  List<Candle> _candles = [];
  Candle? _currentCandle;
  late StreamSubscription<TickData> _subscription;
  final _chartController = ChartController();
  final int _granularity = 60; // 1-minute candles
  
  @override
  void initState() {
    super.initState();
    
    // Subscribe to a tick data stream
    _subscription = tickDataStream.listen((tickData) {
      final tickTime = DateTime.fromMillisecondsSinceEpoch(tickData.timestamp);
      final tickPrice = tickData.price;
      
      setState(() {
        // Update or create the current candle
        if (_currentCandle == null || _isNewCandlePeriod(tickTime)) {
          // If we have a current candle, add it to the list
          if (_currentCandle != null) {
            _candles.add(_currentCandle!);
          }
          
          // Create a new candle
          _currentCandle = Candle(
            epoch: _normalizeTime(tickTime),
            open: tickPrice,
            high: tickPrice,
            low: tickPrice,
            close: tickPrice,
          );
        } else {
          // Update the current candle
          _currentCandle = Candle(
            epoch: _currentCandle!.epoch,
            open: _currentCandle!.open,
            high: max(_currentCandle!.high, tickPrice),
            low: min(_currentCandle!.low, tickPrice),
            close: tickPrice,
          );
        }
        
        _chartController.scrollToLastTick();
      });
    });
  }
  
  bool _isNewCandlePeriod(DateTime time) {
    if (_currentCandle == null) return true;
    
    final currentPeriodStart = _currentCandle!.epoch;
    final currentPeriodEnd = currentPeriodStart.add(Duration(seconds: _granularity));
    
    return time.isAfter(currentPeriodEnd) || time.isAtSameMomentAs(currentPeriodEnd);
  }
  
  DateTime _normalizeTime(DateTime time) {
    // Normalize time to the start of the candle period
    final seconds = (time.second ~/ _granularity) * _granularity;
    return DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      seconds,
    );
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Create a copy of the candles list with the current candle
    final displayCandles = [..._candles];
    if (_currentCandle != null) {
      displayCandles.add(_currentCandle!);
    }
    
    return Chart(
      mainSeries: CandleSeries(displayCandles),
      pipSize: 2,
      granularity: _granularity,
      controller: _chartController,
    );
  }
}
```

## Optimizing Real-time Updates

### Throttling Updates

To prevent excessive UI updates, consider throttling the data updates:

```dart
class ThrottledUpdateChartExample extends StatefulWidget {
  @override
  State<ThrottledUpdateChartExample> createState() => _ThrottledUpdateChartExampleState();
}

class _ThrottledUpdateChartExampleState extends State<ThrottledUpdateChartExample> {
  List<Tick> _ticks = [];
  List<Tick> _pendingTicks = [];
  late StreamSubscription<TickData> _subscription;
  Timer? _updateTimer;
  final _chartController = ChartController();
  
  @override
  void initState() {
    super.initState();
    
    // Subscribe to a tick data stream
    _subscription = tickDataStream.listen((tickData) {
      final tick = Tick(
        epoch: DateTime.fromMillisecondsSinceEpoch(tickData.timestamp),
        quote: tickData.price,
      );
      
      // Add to pending ticks
      _pendingTicks.add(tick);
      
      // Set up a timer to update the UI if not already set
      _updateTimer ??= Timer(Duration(milliseconds: 100), _updateChart);
    });
  }
  
  void _updateChart() {
    if (_pendingTicks.isEmpty) return;
    
    setState(() {
      _ticks.addAll(_pendingTicks);
      _pendingTicks.clear();
      
      // Optional: Limit the number of ticks
      if (_ticks.length > 1000) {
        _ticks = _ticks.sublist(_ticks.length - 1000);
      }
      
      _chartController.scrollToLastTick();
    });
    
    _updateTimer = null;
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _updateTimer?.cancel();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Chart(
      mainSeries: LineSeries(_ticks),
      pipSize: 2,
      controller: _chartController,
    );
  }
}
```

### Using ValueNotifier

For more efficient updates, consider using `ValueNotifier` instead of `setState`:

```dart
class ValueNotifierChartExample extends StatefulWidget {
  @override
  State<ValueNotifierChartExample> createState() => _ValueNotifierChartExampleState();
}

class _ValueNotifierChartExampleState extends State<ValueNotifierChartExample> {
  final ValueNotifier<List<Tick>> _ticksNotifier = ValueNotifier<List<Tick>>([]);
  late StreamSubscription<TickData> _subscription;
  final _chartController = ChartController();
  
  @override
  void initState() {
    super.initState();
    
    // Subscribe to a tick data stream
    _subscription = tickDataStream.listen((tickData) {
      final tick = Tick(
        epoch: DateTime.fromMillisecondsSinceEpoch(tickData.timestamp),
        quote: tickData.price,
      );
      
      // Update the notifier value
      final ticks = [..._ticksNotifier.value, tick];
      
      // Optional: Limit the number of ticks
      if (ticks.length > 1000) {
        _ticksNotifier.value = ticks.sublist(ticks.length - 1000);
      } else {
        _ticksNotifier.value = ticks;
      }
      
      _chartController.scrollToLastTick();
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _ticksNotifier.dispose();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Tick>>(
      valueListenable: _ticksNotifier,
      builder: (context, ticks, _) {
        return Chart(
          mainSeries: LineSeries(ticks),
          pipSize: 2,
          controller: _chartController,
        );
      },
    );
  }
}
```

## Handling WebSocket Connections

For real-time data from WebSocket connections:

```dart
class WebSocketChartExample extends StatefulWidget {
  @override
  State<WebSocketChartExample> createState() => _WebSocketChartExampleState();
}

class _WebSocketChartExampleState extends State<WebSocketChartExample> {
  List<Tick> _ticks = [];
  WebSocketChannel? _channel;
  final _chartController = ChartController();
  bool _isConnected = false;
  
  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }
  
  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your-websocket-endpoint.com'),
    );
    
    setState(() {
      _isConnected = true;
    });
    
    _channel!.stream.listen(
      (data) {
        // Parse the data
        final jsonData = jsonDecode(data);
        final tickData = TickData.fromJson(jsonData);
        
        setState(() {
          _ticks.add(Tick(
            epoch: DateTime.fromMillisecondsSinceEpoch(tickData.timestamp),
            quote: tickData.price,
          ));
          
          // Optional: Limit the number of ticks
          if (_ticks.length > 1000) {
            _ticks = _ticks.sublist(_ticks.length - 1000);
          }
          
          _chartController.scrollToLastTick();
        });
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
        
        // Attempt to reconnect after a delay
        Future.delayed(Duration(seconds: 5), _connectWebSocket);
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
        });
        
        // Attempt to reconnect after a delay
        Future.delayed(Duration(seconds: 5), _connectWebSocket);
      },
    );
    
    // Send subscription message
    _channel!.sink.add(jsonEncode({
      'type': 'subscribe',
      'symbol': 'BTCUSD',
    }));
  }
  
  @override
  void dispose() {
    _channel?.sink.close();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          color: _isConnected ? Colors.green : Colors.red,
          child: Text(
            _isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          child: Chart(
            mainSeries: LineSeries(_ticks),
            pipSize: 2,
            controller: _chartController,
          ),
        ),
      ],
    );
  }
}
```

## Handling Historical and Real-time Data Together

To display historical data and append real-time updates:

```dart
class HistoricalAndRealTimeChartExample extends StatefulWidget {
  @override
  State<HistoricalAndRealTimeChartExample> createState() => _HistoricalAndRealTimeChartExampleState();
}

class _HistoricalAndRealTimeChartExampleState extends State<HistoricalAndRealTimeChartExample> {
  List<Tick> _ticks = [];
  late StreamSubscription<TickData> _subscription;
  final _chartController = ChartController();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Load historical data first
    _loadHistoricalData().then((_) {
      // Then subscribe to real-time updates
      _subscribeToRealTimeData();
    });
  }
  
  Future<void> _loadHistoricalData() async {
    try {
      // Fetch historical data
      final historicalData = await fetchHistoricalData();
      
      setState(() {
        _ticks = historicalData.map((data) => Tick(
          epoch: DateTime.fromMillisecondsSinceEpoch(data.timestamp),
          quote: data.price,
        )).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load historical data: $e')),
      );
    }
  }
  
  void _subscribeToRealTimeData() {
    _subscription = tickDataStream.listen((tickData) {
      // Check if this tick is newer than our latest historical tick
      final tickTime = DateTime.fromMillisecondsSinceEpoch(tickData.timestamp);
      
      if (_ticks.isEmpty || tickTime.isAfter(_ticks.last.epoch)) {
        setState(() {
          _ticks.add(Tick(
            epoch: tickTime,
            quote: tickData.price,
          ));
          
          _chartController.scrollToLastTick();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _chartController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Chart(
      mainSeries: LineSeries(_ticks),
      pipSize: 2,
      controller: _chartController,
    );
  }
  
  Future<List<TickData>> fetchHistoricalData() async {
    // Implement your historical data fetching logic here
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return generateMockHistoricalData();
  }
  
  List<TickData> generateMockHistoricalData() {
    // Generate mock historical data
    final now = DateTime.now();
    final result = <TickData>[];
    double price = 100;
    
    for (int i = 0; i < 100; i++) {
      final time = now.subtract(Duration(minutes: 100 - i));
      price += (Random().nextDouble() - 0.5) * 2;
      
      result.add(TickData(
        timestamp: time.millisecondsSinceEpoch,
        price: price,
      ));
    }
    
    return result;
  }
}
```

## Best Practices

1. **Limit data points**: Keep the number of data points reasonable to maintain performance
2. **Throttle updates**: Don't update the UI on every tick; batch updates for better performance
3. **Handle connection issues**: Implement reconnection logic for WebSocket connections
4. **Provide visual feedback**: Show connection status and loading indicators
5. **Optimize memory usage**: Remove old data points that are no longer needed
6. **Use appropriate data structures**: Choose efficient data structures for your use case
7. **Test with realistic data rates**: Test with realistic data rates to ensure your app can handle the load

## Next Steps

Now that you understand how to handle real-time data in the Deriv Chart library, you can explore:

- [Custom Indicators](custom_indicators.md) - Create custom indicators
- [Custom Drawing Tools](custom_drawing_tools.md) - Implement custom drawing tools