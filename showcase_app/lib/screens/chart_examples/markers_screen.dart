import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'base_chart_screen.dart';

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
  bool _showCrosshair = true;
  bool _useLargeScreenCrosshair = kIsWeb; // Default based on platform
  bool _useDarkTheme = false;
  bool _useDrawingToolsV2 = true;

  @override
  void initState() {
    super.initState();
    _addSampleMarkers();
  }

  void _addSampleMarkers() {
    if (ticks.isEmpty) {
      return;
    }

    // Add some up and down markers at strategic points
    for (int i = 10; i < ticks.length; i += 20) {
      final direction =
          i % 40 == 10 ? MarkerDirection.up : MarkerDirection.down;
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
    if (ticks.isEmpty) {
      return;
    }

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
      showCrosshair: _showCrosshair,
      crosshairVariant: _useLargeScreenCrosshair
          ? CrosshairVariant.largeScreen
          : CrosshairVariant.smallScreen,
      theme: _useDarkTheme ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
      useDrawingToolsV2: _useDrawingToolsV2,
    );
  }

  @override
  Widget buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Theme:'),
              const SizedBox(width: 8),
              const Text('Light'),
              Switch(
                value: _useDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _useDarkTheme = value;
                  });
                },
              ),
              const Text('Dark'),
            ],
          ),
          const SizedBox(height: 16),

          // Crosshair controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Show Crosshair:'),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showCrosshair,
                    onChanged: (value) {
                      setState(() {
                        _showCrosshair = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _useLargeScreenCrosshair = !_useLargeScreenCrosshair;
                  });
                },
                child: Text(
                  'Crosshair: ${_useLargeScreenCrosshair ? 'Large' : 'Small'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Drawing Tools V2 toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Drawing Tools V2:'),
              const SizedBox(width: 8),
              Switch(
                value: _useDrawingToolsV2,
                onChanged: (value) {
                  setState(() {
                    _useDrawingToolsV2 = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
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
