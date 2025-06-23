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
    this.onSwap,
    this.isHidden = false,
    this.showMoveUpIcon = false,
    this.showMoveDownIcon = false,
    this.bottomChartTitleMargin,
    super.currentTickAnimationDuration,
    super.quoteBoundsAnimationDuration,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when an indicator is to be expanded.
  final VoidCallback? onHideUnhideToggle;

  /// Called when an indicator is to moved up/down.
  final SwapCallback? onSwap;

  /// Whether the indicator is hidden or not.
  final bool isHidden;

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
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildCollapsedBottomChart(context),
                  ),
                  _buildDivider(),
                ],
              )
            : Stack(
                children: <Widget>[
                  if (widget.showFrame) _buildChartFrame(context),
                  if (!widget.isHidden)
                    Column(
                      children: <Widget>[
                        Expanded(child: super.build(context)),
                        _buildDivider(),
                      ],
                    ),
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
        showMoveUpIcon: widget.showMoveUpIcon,
        showMoveDownIcon: widget.showMoveDownIcon,
        isHidden: widget.isHidden,
        onHideUnhideToggle: widget.onHideUnhideToggle,
        onSwap: widget.onSwap,
      );

  Widget _buildDivider() => const Divider(
        height: 0.5,
        thickness: 1,
        color: LegacyLightThemeColors.hover,
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

/// Bottom chart options for mobile.
class IndicatorLabelMobile extends StatelessWidget {
  /// Initializes a bottom chart indicator label.
  const IndicatorLabelMobile({
    required this.title,
    required this.showMoveUpIcon,
    required this.showMoveDownIcon,
    required this.isHidden,
    this.onHideUnhideToggle,
    this.onSwap,
    super.key,
  });

  /// The title of the indicator.
  final String title;

  /// Whether to show the move up icon.
  final bool showMoveUpIcon;

  /// Whether to show the move down icon.
  final bool showMoveDownIcon;

  /// Whether the indicator is hidden or not.
  final bool isHidden;

  /// Called when an indicator is to be expanded.
  final VoidCallback? onHideUnhideToggle;

  /// Called when an indicator is to moved up/down.
  final SwapCallback? onSwap;

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
              // Different styling for mobile version.
              BottomIndicatorTitle(
                title,
                theme.textStyle(
                  color: theme.base01Color,
                  textStyle: theme.textStyle(
                    textStyle: TextStyles.caption,
                    color: theme.base01Color,
                  ),
                ),
              ),
              const SizedBox(width: Dimens.margin08),
              _buildIcons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcons(BuildContext context) => Row(
        children: <Widget>[
          _buildIcon(
            iconData: isHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            context: context,
            onPressed: () {
              onHideUnhideToggle?.call();
            },
          ),
          if (showMoveUpIcon)
            _buildIcon(
              iconData: Icons.arrow_upward,
              context: context,
              onPressed: () {
                onSwap?.call(-1);
              },
            ),
          if (showMoveDownIcon)
            _buildIcon(
              iconData: Icons.arrow_downward,
              context: context,
              onPressed: () {
                onSwap?.call(1);
              },
            ),
        ],
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
