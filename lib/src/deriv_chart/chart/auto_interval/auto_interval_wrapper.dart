import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'zoom_level_observer.dart';
import '../../../models/chart_axis_config.dart';

/// Auto-interval wrapper widget that manages automatic granularity switching.
///
/// This widget wraps chart components and automatically manages granularity
/// changes based on zoom levels. It provides a clean interface similar to
/// GestureManager and XAxisWrapper.
///
/// Usage:
/// ```dart
/// AutoIntervalWrapper(
///   enabled: true,
///   granularity: currentGranularity,
///   zoomRanges: autoIntervalRanges,
///   onGranularityChangeRequested: (newGranularity) {
///     // Handle granularity change request
///   },
///   child: ...
/// )
/// ```
class AutoIntervalWrapper extends StatefulWidget {
  /// Creates an auto-interval wrapper.
  const AutoIntervalWrapper({
    required this.child,
    required this.granularity,
    this.enabled = false,
    this.zoomRanges = defaultAutoIntervalRanges,
    this.onGranularityChangeRequested,
    Key? key,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// Current granularity in milliseconds.
  final int granularity;

  /// Whether auto-interval is enabled.
  final bool enabled;

  /// Zoom range configurations for auto-interval.
  final List<AutoIntervalZoomRange> zoomRanges;

  /// Called when a granularity change is suggested.
  final void Function(int suggestedGranularity)? onGranularityChangeRequested;

  @override
  AutoIntervalWrapperState createState() => AutoIntervalWrapperState();
}

/// State for AutoIntervalWrapper that implements ZoomLevelObserver.
class AutoIntervalWrapperState extends State<AutoIntervalWrapper>
    implements ZoomLevelObserver {
  late int _currentGranularity;
  double? _currentMsPerPx;
  int? _lastSuggestedGranularity;

  @override
  void initState() {
    super.initState();
    _currentGranularity = widget.granularity;
  }

  @override
  void didUpdateWidget(AutoIntervalWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update granularity if it changed externally
    if (oldWidget.granularity != widget.granularity) {
      _currentGranularity = widget.granularity;
      _lastSuggestedGranularity = null; // Reset suggestion tracking
    }

    // Suggest granularity change if auto-interval is re-enabled.
    if (!oldWidget.enabled && widget.enabled) {
      _requestGranularityChangeIfNeeded();
    }
  }

  @override
  void onZoomLevelChanged(double msPerPx, int currentGranularity) {
    // Update current granularity and msPerPx
    _currentGranularity = currentGranularity;
    _currentMsPerPx = msPerPx;

    // Calculate optimal granularity for current zoom level if auto-interval
    // is enabled.
    if (widget.enabled) {
      _requestGranularityChangeIfNeeded();
    }
  }

  /// Calculates the optimal granularity for the given zoom level
  int? _calculateOptimalGranularity(double msPerPx) {
    AutoIntervalZoomRange? bestRange;
    double bestScore = double.infinity;

    for (final AutoIntervalZoomRange range in widget.zoomRanges) {

      // The number of pixels that one interval (candle) will occupy on the
      // chart at current zoom level.
      final double pixelsPerInterval = range.granularity / msPerPx;

      // Check if current zoom level fits within this range's bounds
      if (pixelsPerInterval >= range.minPixelsPerInterval &&
          pixelsPerInterval <= range.maxPixelsPerInterval) {
        // Calculate score based on distance from optimal
        final double score =
            (pixelsPerInterval - range.optimalPixelsPerInterval).abs();

        if (score < bestScore) {
          bestScore = score;
          bestRange = range;
        }
      }
    }

    return bestRange?.granularity;
  }

  /// Requests a granularity change if the optimal granularity is different
  /// from the current and not already requested.
  void _requestGranularityChangeIfNeeded() {
    if (_currentMsPerPx == null) {
      return;
    }

    final int? optimalGranularity =
        _calculateOptimalGranularity(_currentMsPerPx!);

    if (optimalGranularity != null &&
        optimalGranularity != _currentGranularity &&
        optimalGranularity != _lastSuggestedGranularity) {
      _lastSuggestedGranularity = optimalGranularity;
      // Defer the callback to the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onGranularityChangeRequested?.call(optimalGranularity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ZoomLevelObserver>.value(
      value: this,
      child: widget.child,
    );
  }
}
