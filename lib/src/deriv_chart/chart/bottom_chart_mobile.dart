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
                  _buildCollapsedBottomChart(context),
                  _buildDivider(),
                ],
              )
            : Stack(
                children: <Widget>[
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

  Widget _buildIndicatorLabelMobile() => IndicatorLabelMobile(
        title: widget.title,
        showMoveUpIcon: widget.showMoveUpIcon,
        showMoveDownIcon: widget.showMoveDownIcon,
        isHidden: widget.isHidden,
        onHideUnhideToggle: widget.onHideUnhideToggle,
        onSwap: widget.onSwap,
      );

  Widget _buildDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.margin04),
        child: Divider(
          height: 0.5,
          thickness: 1,
          color: theme.hoverColor,
        ),
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
    return Container(
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
            title,
            theme.textStyle(
              color: theme.base01Color,
              textStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: Dimens.margin16),
          _buildIcons(context),
        ],
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
      Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(
            iconData,
            size: 16,
            color: context.read<ChartTheme>().base01Color,
          ),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
}
