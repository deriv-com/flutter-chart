import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis.dart';
import 'package:flutter/scheduler.dart';

/// XAxisMobile
class XAxisMobile extends XAxis {
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
    super.maxCurrentTickOffset,
    super.msPerPx,
    super.minIntervalWidth,
    super.maxIntervalWidth,
    super.dataFitPadding,
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
