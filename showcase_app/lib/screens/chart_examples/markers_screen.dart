import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:showcase_app/screens/chart_examples/base_chart_screen.dart';

/// Screen that displays a chart with markers.
class MarkersScreen extends BaseChartScreen {
  /// Initialize the markers screen.
  const MarkersScreen({Key? key}) : super(key: key);

  @override
  State<MarkersScreen> createState() => _MarkersScreenState();
}

class _MarkersScreenState extends BaseChartScreenState<MarkersScreen> {
  final SplayTreeSet<Marker> _markers = SplayTreeSet<Marker>();
  ActiveMarker? _activeMarker;
  
  @override
  void initState() {
    super.initState();
    _addSampleMarkers();
  }
  
  void _addSampleMarkers() {
    if (ticks.isEmpty) return;
    
    // Add some up and down markers at strategic points
    for (int i = 10; i < ticks.length; i += 20) {
      final direction = i % 40 == 10 ? MarkerDirection.up : MarkerDirection.down;
      _markers.add(Marker(
        direction: direction,
        epoch: ticks[i].epoch,
        quote: ticks[i].quote,
        onTap: () => _onMarkerTap(ticks[i]),
      ));
    }
  }
  
  void _onMarkerTap(Tick tick) {
    setState(() {
      _activeMarker = ActiveMarker(
        direction: MarkerDirection.up,
        epoch: tick.epoch,
        quote: tick.quote,
        text: '${tick.quote.toStringAsFixed(2)} USD',
        onTap: () {
          // Do something when active marker is tapped
        },
        onTapOutside: () {
          setState(() {
            _activeMarker = null;
          });
        },
      );
    });
  }
  
  void _addMarker(MarkerDirection direction) {
    if (ticks.isEmpty) return;
    
    final lastTick = ticks.last;
    
    setState(() {
      _markers.add(Marker(
        direction: direction,
        epoch: lastTick.epoch,
        quote: lastTick.quote,
        onTap: () => _onMarkerTap(lastTick),
      ));
    });
  }
  
  void _clearMarkers() {
    setState(() {
      _markers.clear();
      _activeMarker = null;
    });
  }
  
  @override
  String getTitle() => 'Chart with Markers';

  @override
  Widget buildChart() {
    return DerivChart(
      key: const Key('markers_chart'),
      mainSeries: LineSeries(ticks, style: const LineStyle(hasArea: true)),
      markerSeries: MarkerSeries(
        _markers,
        activeMarker: _activeMarker,
        markerIconPainter: MultipliersMarkerIconPainter(),
      ),
      controller: controller,
      pipSize: 2,
      granularity: 60000, // 1 minute
      activeSymbol: 'MARKERS_CHART',
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Add Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _addMarker(MarkerDirection.up),
                ),
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Add Down'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _addMarker(MarkerDirection.down),
                ),
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  onPressed: _clearMarkers,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap on any marker to see active marker details',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
