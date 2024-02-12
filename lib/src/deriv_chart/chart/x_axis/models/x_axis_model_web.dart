import 'package:deriv_chart/src/deriv_chart/chart/x_axis/models/x_axis_model.dart';

/// XAxisModelWeb
class XAxisModelWeb extends XAxisModel {
  /// Initialize
  XAxisModelWeb({
    required super.entries,
    required super.granularity,
    required super.animationController,
    required super.isLive,
  });

  /// Enables data fit viewing mode.
  @override
  void enableDataFit() {
    fitAvailableData();
    super.enableDataFit();
  }
}
