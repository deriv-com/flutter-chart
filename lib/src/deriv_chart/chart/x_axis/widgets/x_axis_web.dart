import 'package:deriv_chart/src/deriv_chart/chart/x_axis/widgets/x_axis_base.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

/// A class representing the X-axis for a web-based chart.
///
/// This class extends [XAxisBase], providing additional functionality
/// specific to web-based chart.
class XAxisWeb extends XAxisBase {
  /// Initialize
  const XAxisWeb({
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
    super.key,
  });

  @override
  _XAxisStateWeb createState() => _XAxisStateWeb();
}

class _XAxisStateWeb extends XAxisState {
  AnimationController? _scrollAnimationController;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();

    // Add continuous frame updates for proper auto-scrolling
    _ticker = createTicker(model.onNewFrame)..start();

    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollAnimationDuration,
    );

    final CurvedAnimation scrollAnimation = CurvedAnimation(
      parent: _scrollAnimationController!,
      curve: Curves.easeOut,
    );

    final int granularity = context.read<ChartConfig>().granularity;

    int prevOffsetEpoch = 0;

    scrollAnimation.addListener(
      () {
        if (scrollAnimation.value == 0) {
          prevOffsetEpoch = 0;
        }

        final int offsetEpoch = (scrollAnimation.value * granularity).toInt();

        model.scrollAnimationListener(offsetEpoch - prevOffsetEpoch);
        prevOffsetEpoch = offsetEpoch;
      },
    );

    fitData();
  }

  @override
  void didUpdateWidget(XAxisBase oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_scrollAnimationController != null &&
        oldWidget.entries.isNotEmpty &&
        widget.entries.isNotEmpty &&
        oldWidget.entries.last.epoch != widget.entries.last.epoch) {
      _scrollAnimationController!
        ..reset()
        ..forward();

      fitData();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollAnimationController?.dispose();

    super.dispose();
  }

  void fitData() {
    if (model.dataFitEnabled) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        model.fitAvailableData();
      });
    }
  }
}
