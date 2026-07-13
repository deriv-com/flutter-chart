import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';

/// This class includes dimensions according to Deriv design guidelines.
///
/// More dimens values can be added here following the convention margin_x
/// In case of a theme change, use IDE refactoring technique to rename the value
/// So it can be reflected wherever it is used with ease.
class Dimens {
  /// Tiny margin.
  static const double margin04 = 4;

  /// Small margin.
  static const double margin08 = 8;

  /// Custom margin.
  static const double margin12 = 12;

  /// Normal  margin.
  static const double margin16 = 16;

  /// Large  margin.
  static const double margin24 = 24;

  /// X-Large  margin.
  static const double margin32 = 32;

  /// Border radius small.
  static const double borderRadius04 = 4;

  /// Border radius medium.
  static const double borderRadius08 = 8;

  /// Border radius large.
  static const double borderRadius16 = 16;

  /// Border radius x-large.
  static const double borderRadius24 = 24;

  /// 1.5 rem (Value: 24)
  static const double crosshairInformationBoxContainerGlassBackgroundBlur =
      CoreDesignTokens.coreSize1200;

  /// Default area line thickness 1
  static const double areaLineDefaultThickness = 1;

  /// Medium area line thickness 1.5
  static const double areaLineMediumThickness = 1.5;

  /// Large area line thickness 2
  static const double areaLineLargeThickness = 2;

  /// Minimum height a chart panel (main chart or a bottom indicator panel)
  /// can be resized down to via [ResizableChartDivider], expressed as a
  /// fraction of the total space shared by all panels in its chain rather
  /// than a fixed pixel amount. A fixed pixel minimum ends up too large a
  /// share of the screen on small devices (e.g. with the maximum of 3
  /// indicators on a short screen); a fixed fraction scales down with the
  /// screen instead.
  static const double minChartPanelHeightFraction = 0.1;

  /// Height of the hit area for [ResizableChartDivider]. Sized well above
  /// its visible line so the drag target stays comfortably tappable on
  /// touch devices.
  static const double chartPanelDividerHitHeight = 40;

  /// Width of the touch hit area around [ResizableChartDivider]'s drag
  /// handle on mobile - wider than the visible handle so it's easy to tap
  /// and grab without needing pixel-perfect accuracy.
  static const double chartPanelDividerHandleHitWidth = 64;
}
