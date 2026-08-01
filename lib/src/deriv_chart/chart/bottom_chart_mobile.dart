import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/mobile_chart_frame_dividers.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/dimens.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:deriv_chart/src/widgets/bottom_indicator_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'basic_chart.dart';
import 'bottom_chart.dart';
import 'data_visualization/chart_series/series.dart';
import 'indicator_label_icons.dart';
import 'x_axis/x_axis_model.dart';

/// Mobile version of the chart to add the bottom indicators too.
class BottomChartMobile extends BasicChart {
  /// Initializes a bottom chart mobile.
  const BottomChartMobile({
    required Series series,
    required this.granularity,
    required this.title,
    this.showFrame = true,
    int pipSize = 4,
    Key? key,
    this.onHideUnhideToggle,
    this.onEdit,
    this.onRemove,
    this.onExpandToggle,
    this.onSwap,
    this.isHidden = false,
    this.isExpanded = false,
    this.showMoveUpIcon = false,
    this.showMoveDownIcon = false,
    this.bottomChartTitleMargin,
    this.icons = const IndicatorLabelIcons(),
    super.currentTickAnimationDuration,
    super.quoteBoundsAnimationDuration,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when the indicator's data is hidden/unhidden (eye icon).
  final VoidCallback? onHideUnhideToggle;

  /// Called when the indicator's settings are to be edited (gear icon).
  final VoidCallback? onEdit;

  /// Called when the indicator is to be removed (trash icon).
  final VoidCallback? onRemove;

  /// Called when the indicator's label is expanded/collapsed (chevron icon).
  final VoidCallback? onExpandToggle;

  /// Called when an indicator is to moved up/down.
  final SwapCallback? onSwap;

  /// Whether the indicator's data is hidden or not.
  final bool isHidden;

  /// Whether the indicator's label is expanded (showing its action buttons)
  /// or collapsed (showing only its title and a chevron).
  final bool isExpanded;

  /// The title of the bottom chart.
  final String title;

  /// Whether the move up icon should be shown or not.
  final bool showMoveUpIcon;

  /// Whether the move down icon should be shown or not.
  final bool showMoveDownIcon;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  /// Whether to show the frame or not.
  final bool showFrame;

  /// The icons used by the indicator label. Defaults to Material icons.
  final IndicatorLabelIcons icons;

  @override
  _BottomChartMobileState createState() => _BottomChartMobileState();
}

class _BottomChartMobileState extends BasicChartState<BottomChartMobile> {
  ChartTheme get theme => context.read<ChartTheme>();

  @override
  Widget build(BuildContext context) {
    final ChartConfig chartConfig = ChartConfig(
      pipSize: widget.pipSize,
      granularity: widget.granularity,
    );

    return Provider<ChartConfig>.value(
      value: chartConfig,
      child: ClipRect(
        child: widget.isHidden
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildCollapsedBottomChart(context),
              )
            : Stack(
                children: <Widget>[
                  if (widget.showFrame) _buildChartFrame(context),
                  if (!widget.isHidden) super.build(context),
                  Positioned(
                    top: 4,
                    left: widget.bottomChartTitleMargin?.left ?? 10,
                    child: _buildIndicatorLabelMobile(),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildChartFrame(BuildContext context) => Container(
        constraints: const BoxConstraints.expand(),
        child: MobileChartFrameDividers(
          color: LegacyLightThemeColors.hover,
          rightPadding: (context.read<XAxisModel>().rightPadding ?? 0) +
              context.read<ChartTheme>().gridStyle.labelHorizontalPadding,
          sides: const ChartFrameSides(right: true),
        ),
      );

  Widget _buildIndicatorLabelMobile() => IndicatorLabelMobile(
        title: widget.title,
        isExpanded: widget.isExpanded,
        showMoveUpIcon: widget.showMoveUpIcon,
        showMoveDownIcon: widget.showMoveDownIcon,
        isHidden: widget.isHidden,
        icons: widget.icons,
        onExpandToggle: widget.onExpandToggle,
        onHideUnhideToggle: widget.onHideUnhideToggle,
        onEdit: widget.onEdit,
        onRemove: widget.onRemove,
        onSwap: widget.onSwap,
      );

  Widget _buildCollapsedBottomChart(BuildContext context) => Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.bottomChartTitleMargin?.left ?? 10,
          ),
          child: _buildIndicatorLabelMobile(),
        ),
      );

  @override
  void didUpdateWidget(BottomChartMobile oldChart) {
    super.didUpdateWidget(oldChart);

    xAxis.update(
      minEpoch: widget.mainSeries.getMinEpoch(),
      maxEpoch: widget.mainSeries.getMaxEpoch(),
    );
  }
}

/// The on-chart indicator label shown at the top-left of an indicator's panel
/// (for bottom indicators) or the main chart (for overlay indicators).
///
/// It has two states, toggled by the trailing chevron:
///  * **Collapsed** - shows only the indicator's title and a chevron pointing
///    right (the expand affordance).
///  * **Expanded** - additionally reveals the action buttons: hide/unhide
///    (eye), reorder (up/down, when applicable), settings (gear) and delete
///    (trash), with the chevron pointing left (the collapse affordance).
///
/// Expanding/collapsing only affects which action buttons are shown; it never
/// hides the indicator's data - that is controlled independently by the eye
/// (hide/unhide) button.
class IndicatorLabelMobile extends StatelessWidget {
  /// Initializes a bottom chart indicator label.
  const IndicatorLabelMobile({
    required this.title,
    required this.isExpanded,
    required this.showMoveUpIcon,
    required this.showMoveDownIcon,
    required this.isHidden,
    this.icons = const IndicatorLabelIcons(),
    this.onExpandToggle,
    this.onHideUnhideToggle,
    this.onEdit,
    this.onRemove,
    this.onSwap,
    super.key,
  });

  /// The title of the indicator.
  final String title;

  /// The icons rendered in the label. Defaults to Material icons.
  final IndicatorLabelIcons icons;

  /// Whether the label is expanded (showing its action buttons) or not.
  final bool isExpanded;

  /// Whether to show the move up icon.
  final bool showMoveUpIcon;

  /// Whether to show the move down icon.
  final bool showMoveDownIcon;

  /// Whether the indicator's data is hidden or not.
  final bool isHidden;

  /// Called when the label is expanded/collapsed (chevron icon).
  final VoidCallback? onExpandToggle;

  /// Called when the indicator's data is hidden/unhidden (eye icon).
  final VoidCallback? onHideUnhideToggle;

  /// Called when the indicator's settings are to be edited (gear icon).
  final VoidCallback? onEdit;

  /// Called when the indicator is to be removed (trash icon).
  final VoidCallback? onRemove;

  /// Called when an indicator is to moved up/down.
  final SwapCallback? onSwap;

  /// Duration of the expand/collapse transition.
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.read<ChartTheme>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.margin04),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: theme.crosshairInformationBoxContainerGlassBackgroundBlur,
            sigmaY: theme.crosshairInformationBoxContainerGlassBackgroundBlur),
        child: Container(
          padding: const EdgeInsets.all(Dimens.margin04),
          decoration: BoxDecoration(
            color: theme.crosshairInformationBoxContainerGlassColor,
            borderRadius: BorderRadius.circular(Dimens.margin04),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Tapping the title toggles expand/collapse, matching the chevron.
              GestureDetector(
                onTap: onExpandToggle,
                behavior: HitTestBehavior.opaque,
                child: BottomIndicatorTitle(
                  title,
                  theme.textStyle(
                    color: theme.base01Color,
                    textStyle: theme.textStyle(
                      textStyle: TextStyles.caption,
                      color: theme.base01Color,
                    ),
                  ),
                ),
              ),
              // The action buttons slide in/out horizontally as the label is
              // expanded/collapsed. [AnimatedSize] animates (and clips) the
              // width between the full action row and nothing.
              AnimatedSize(
                duration: _animationDuration,
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                child: isExpanded
                    ? _buildActions(context)
                    : const SizedBox.shrink(),
              ),
              _buildChevron(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildIcon(
            iconData: isHidden ? icons.hide : icons.show,
            context: context,
            onPressed: () {
              onHideUnhideToggle?.call();
            },
          ),
          if (showMoveUpIcon)
            _buildIcon(
              iconData: icons.moveUp,
              context: context,
              onPressed: () {
                onSwap?.call(-1);
              },
            ),
          if (showMoveDownIcon)
            _buildIcon(
              iconData: icons.moveDown,
              context: context,
              onPressed: () {
                onSwap?.call(1);
              },
            ),
          if (onEdit != null)
            _buildIcon(
              iconData: icons.settings,
              context: context,
              onPressed: () {
                onEdit?.call();
              },
            ),
          if (onRemove != null)
            _buildIcon(
              iconData: icons.delete,
              context: context,
              onPressed: () {
                onRemove?.call();
              },
            ),
        ],
      );

  /// The trailing chevron that toggles the expanded/collapsed state. It points
  /// right when collapsed and rotates to point left when expanded.
  Widget _buildChevron(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: Dimens.margin08),
        child: Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            icon: AnimatedRotation(
              duration: _animationDuration,
              curve: Curves.easeInOut,
              turns: isExpanded ? 0.5 : 0.0,
              child: Icon(
                icons.expandCollapse,
                size: 16,
                color: context.read<ChartTheme>().base01Color,
              ),
            ),
            onPressed: onExpandToggle,
            padding: const EdgeInsets.all(Dimens.margin04),
            constraints: const BoxConstraints(),
          ),
        ),
      );

  Widget _buildIcon({
    required IconData iconData,
    required BuildContext context,
    void Function()? onPressed,
  }) =>
      Padding(
        padding: const EdgeInsets.only(left: Dimens.margin08),
        child: Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            icon: Icon(
              iconData,
              size: 16,
              color: context.read<ChartTheme>().base01Color,
            ),
            onPressed: onPressed,
            padding: const EdgeInsets.all(Dimens.margin04),
            constraints: const BoxConstraints(),
          ),
        ),
      );
}
