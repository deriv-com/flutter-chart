import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_default_theme.dart';
import 'package:flutter/material.dart';

import 'basic_chart.dart';

/// The chart to add the bottom indicators too.
class BottomChart extends BasicChart {
  /// Initializes a bottom chart.
  const BottomChart({
    required Series series,
    int pipSize = 4,
    Key? key,
    this.onRemove,
    this.onEdit,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  /// Called when an indicator is to be removed.
  final OnRemoveCallback? onRemove;

  /// Called when an indicator is to be edited.
  final OnEditCallback? onEdit;

  @override
  _BottomChartState createState() => _BottomChartState();
}

class _BottomChartState extends BasicChartState<BottomChart> {
  Widget _buildBottomChartOptions(BuildContext context) {
    final ChartDefaultTheme theme =
        Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();

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
            Text(
              widget.mainSeries.runtimeType.toString(),
            ),
            Material(
              type: MaterialType.circle,
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 16,
                ),
                onPressed: () => widget.onEdit?.call(widget.mainSeries.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Material(
              type: MaterialType.circle,
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 16,
                ),
                onPressed: () => widget.onRemove?.call(widget.mainSeries.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
