import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// XAxisWeb
class XAxisWeb extends XAxis {
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
    super.maxCurrentTickOffset,
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

  @override
  void initState() {
    super.initState();

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
  void didUpdateWidget(XAxis oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_scrollAnimationController != null &&
        oldWidget.entries != widget.entries) {
      _scrollAnimationController!
        ..reset()
        ..forward();

      fitData();
    }
  }

  @override
  void dispose() {
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
