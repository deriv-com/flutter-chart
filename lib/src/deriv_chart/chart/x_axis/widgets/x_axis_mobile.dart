import 'package:deriv_chart/src/deriv_chart/chart/x_axis/widgets/x_axis_base.dart';
import 'package:flutter/scheduler.dart';

/// A class representing the X-axis for a mobile-based chart.
///
/// This class extends [XAxisBase], providing additional functionality
/// specific to mobile-based chart.
class XAxisMobile extends XAxisBase {
  /// Initialize
  const XAxisMobile({
    required super.entries,
    required super.child,
    required super.isLive,
    required super.startWithDataFitMode,
    required super.pipSize,
    required super.scrollAnimationDuration,
    super.onVisibleAreaChanged,
    super.minEpoch,
    super.maxEpoch,
    super.msPerPx,
    super.minIntervalWidth,
    super.maxIntervalWidth,
    super.dataFitPadding,
    super.defaultTickOffset,
    super.key,
  });

  @override
  _XAxisStateMobile createState() => _XAxisStateMobile();
}

class _XAxisStateMobile extends XAxisState {
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(model.onNewFrame)..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}
