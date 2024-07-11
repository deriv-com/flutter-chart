import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/dimens.dart';
import 'package:deriv_chart/src/widgets/bottom_indicator_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'basic_chart.dart';
import 'bottom_chart.dart';
import 'data_visualization/chart_series/series.dart';

/// Mobile version of the chart to add the bottom indicators too.
class BottomChartMobile extends BasicChart {
  /// Initializes a bottom chart mobile.
  const BottomChartMobile({
    required Series series,
    required this.granularity,
    required this.title,
    int pipSize = 4,
    Key? key,
    this.onRemove,
    this.onEdit,
    this.onHideUnhideToggle,
    this.onSwap,
    this.isHidden = false,
    this.showHideIcon = false,
    this.showMoveUpIcon = false,
    this.showMoveDownIcon = false,
    this.bottomChartTitleMargin,
    super.currentTickAnimationDuration,
    super.quoteBoundsAnimationDuration,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when an indicator is to be removed.
  final VoidCallback? onRemove;

  /// Called when an indicator is to be edited.
  final VoidCallback? onEdit;

  /// Called when an indicator is to be expanded.
  final VoidCallback? onHideUnhideToggle;

  /// Called when an indicator is to moved up/down.
  final SwapCallback? onSwap;

  /// Whether the indicator is hidden or not.
  final bool isHidden;

  /// The title of the bottom chart.
  final String title;

  /// Whether the hide/unhide icon should be shown or not.
  final bool showHideIcon;

  /// Whether the move up icon should be shown or not.
  final bool showMoveUpIcon;

  /// Whether the move down icon should be shown or not.
  final bool showMoveDownIcon;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  @override
  _BottomChartMobileState createState() => _BottomChartMobileState();
}

class _BottomChartMobileState extends BasicChartState<BottomChartMobile> {
  ChartTheme get theme => context.read<ChartTheme>();

  Widget _buildIcon({
    required IconData iconData,
    void Function()? onPressed,
  }) =>
      Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(
            iconData,
            size: 16,
            color: theme.base01Color,
          ),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );

  Widget _buildIcons() => Row(
        children: <Widget>[
          if (widget.showHideIcon)
            _buildIcon(
              iconData: widget.isHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onPressed: () {
                widget.onHideUnhideToggle?.call();
              },
            ),
          if (widget.showMoveUpIcon)
            _buildIcon(
              iconData: Icons.arrow_upward,
              onPressed: () {
                widget.onSwap?.call(-1);
              },
            ),
          if (widget.showMoveDownIcon)
            _buildIcon(
              iconData: Icons.arrow_downward,
              onPressed: () {
                widget.onSwap?.call(1);
              },
            ),
        ],
      );

  Widget _buildBottomChartOptions(BuildContext context) => Container(
        padding: const EdgeInsets.all(Dimens.margin04),
        decoration: BoxDecoration(
          color: theme.hoverColor,
          borderRadius: BorderRadius.circular(Dimens.margin04),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Different styling for mobile version.
            BottomIndicatorTitle(
              widget.title,
              theme.textStyle(
                color: theme.base01Color,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: Dimens.margin16),
            _buildIcons(),
          ],
        ),
      );

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
            ? Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: widget.bottomChartTitleMargin?.left ?? 10,
                  ),
                  child: _buildBottomChartOptions(context),
                ),
              )
            : Stack(
                children: <Widget>[
                  if (!widget.isHidden)
                    Column(
                      children: <Widget>[
                        Divider(
                          height: 0.5,
                          thickness: 1,
                          color: theme.base01Color,
                        ),
                        Expanded(child: super.build(context)),
                      ],
                    ),
                  Positioned(
                    top: 4,
                    left: widget.bottomChartTitleMargin?.left ?? 10,
                    child: _buildBottomChartOptions(context),
                  )
                ],
              ),
      ),
    );
  }

  @override
  void didUpdateWidget(BottomChartMobile oldChart) {
    super.didUpdateWidget(oldChart);

    xAxis.update(
      minEpoch: widget.mainSeries.getMinEpoch(),
      maxEpoch: widget.mainSeries.getMaxEpoch(),
    );
  }
}
