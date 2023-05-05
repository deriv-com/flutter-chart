import 'package:deriv_chart/src/widgets/bottom_indicator_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/crosshair_area_web.dart';
import 'package:deriv_chart/src/theme/chart_default_theme.dart';

import 'basic_chart.dart';

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
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.showCrosshair = true,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  /// Called when an indicator is to be removed.
  final VoidCallback? onRemove;

  /// Called when an indicator is to be edited.
  final VoidCallback? onEdit;

  /// Called when candle or point is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHoverCallback? onCrosshairHover;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// The title of the bottom chart.
  final String title;

  @override
  _BottomChartState createState() => _BottomChartState();
}

class _BottomChartState extends BasicChartState<BottomChart> {
  Widget _buildBottomChartOptions(BuildContext context) {
    final ChartDefaultTheme theme =
        Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();

    Widget _buildEditIcon() => Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            icon: const Icon(
              Icons.settings,
              size: 16,
            ),
            onPressed: () {
              widget.onEdit?.call();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        );

    Widget _buildRemoveIcon() => Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            icon: const Icon(
              Icons.delete,
              size: 16,
            ),
            onPressed: () {
              widget.onRemove?.call();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
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
            _buildEditIcon(),
            _buildRemoveIcon()
          ],
        ),
      ),
    );
  }

  Widget _buildCrosshairAreaWeb() => CrosshairAreaWeb(
        mainSeries: widget.mainSeries,
        epochFromCanvasX: xAxis.epochFromX,
        quoteFromCanvasY: chartQuoteFromCanvasY,
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
