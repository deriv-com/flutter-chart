import 'package:deriv_chart/src/widgets/bottom_indicator_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/crosshair_area_web.dart';
import 'package:deriv_chart/src/theme/chart_default_theme.dart';

import 'basic_chart.dart';

/// Called when the indicator is moved up/down
///
/// [offset] is the displacement between the swap positions.
typedef SwapCallback = Function(int offset);

/// The chart to add the bottom indicators too.
class BottomChart extends BasicChart {
  /// Initializes a bottom chart.
  const BottomChart({
    required Series series,
    required this.title,
    int pipSize = 4,
    Key? key,
    this.onRemove,
    this.onEdit,
    this.onExpandToggle,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onSwap,
    this.isExpanded = false,
    this.showCrosshair = true,
    this.showExpandedIcon = false,
    this.showMoveUpIcon = false,
    this.showMoveDownIcon = false,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  /// Called when an indicator is to be removed.
  final VoidCallback? onRemove;

  /// Called when an indicator is to be edited.
  final VoidCallback? onEdit;

  /// Called when an indicator is to be expanded.
  final VoidCallback? onExpandToggle;

  /// Called when an indicator is to moved up/down.
  final SwapCallback? onSwap;

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHover? onCrosshairHover;

  /// Whether the indicator is expanded or not.
  final bool isExpanded;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// The title of the bottom chart.
  final String title;

  /// Whether the expanded icon should be shown or not.
  final bool showExpandedIcon;

  /// Whether the move up icon should be shown or not.
  final bool showMoveUpIcon;

  /// Whether the move down icon should be shown or not.
  final bool showMoveDownIcon;

  @override
  _BottomChartState createState() => _BottomChartState();
}

class _BottomChartState extends BasicChartState<BottomChart> {
  Widget _buildBottomChartOptions(BuildContext context) {
    final ChartDefaultTheme theme =
        Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();

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
            ),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        );

    Widget _buildIcons() => Row(
          children: <Widget>[
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
            if (widget.showExpandedIcon)
              _buildIcon(
                iconData: widget.isExpanded
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                onPressed: () {
                  widget.onExpandToggle?.call();
                },
              ),
            _buildIcon(
              iconData: Icons.settings,
              onPressed: () {
                widget.onEdit?.call();
              },
            ),
            _buildIcon(
              iconData: Icons.delete,
              onPressed: () {
                widget.onRemove?.call();
              },
            ),
          ],
        );

    return Positioned(
      top: 15,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: theme.base01Color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: <Widget>[
            BottomIndicatorTitle(widget.title),
            _buildIcons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCrosshairAreaWeb() => CrosshairAreaWeb(
        mainSeries: widget.mainSeries,
        epochFromCanvasX: xAxis.epochFromX,
        quoteFromCanvasY: chartQuoteFromCanvasY,
        epochToCanvasX: xAxis.xFromEpoch,
        quoteToCanvasY: chartQuoteToCanvasY,
        quoteLabelsTouchAreaWidth: quoteLabelsTouchAreaWidth,
        showCrosshairCursor: widget.showCrosshair,
        onCrosshairDisappeared: widget.onCrosshairDisappeared,
        onCrosshairHover: widget.onCrosshairHover,
      );

  @override
  Widget build(BuildContext context) => ClipRect(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Colors.black,
                ),
                Expanded(child: super.build(context)),
              ],
            ),
            if (kIsWeb) _buildCrosshairAreaWeb(),
            _buildBottomChartOptions(context)
          ],
        ),
      );

  @override
  void didUpdateWidget(BottomChart oldChart) {
    super.didUpdateWidget(oldChart);

    xAxis.update(
      minEpoch: widget.mainSeries.getMinEpoch(),
      maxEpoch: widget.mainSeries.getMaxEpoch(),
    );
  }
}
