import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_default_theme.dart';
import 'package:flutter/material.dart';

import 'basic_chart.dart';
import 'y_axis/quote_grid.dart';

/// The chart to add the bottom indicators too.
class BottomChart extends BasicChart {
  /// Initializes a bottom chart.
  const BottomChart({
    required Series series,
    int pipSize = 4,
    Key? key,
  }) : super(key: key, mainSeries: series, pipSize: pipSize);

  @override
  _BottomChartState createState() => _BottomChartState();
}

class _BottomChartState extends BasicChartState<BottomChart> {
  @override
  Widget build(BuildContext context) {
    final ChartDefaultTheme theme =
        Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme();
    return ClipRect(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Divider(
                height: 0.5,
                thickness: 1,
                color: theme.brandGreenishColor,
              ),
              Expanded(child: super.build(context)),
            ],
          ),
          Positioned(
            top: 15,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.base01Color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                widget.mainSeries.runtimeType.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(BottomChart oldChart) {
    super.didUpdateWidget(oldChart);

    xAxis.update(
      minEpoch: widget.mainSeries.getMinEpoch(),
      maxEpoch: widget.mainSeries.getMaxEpoch(),
    );
  }
}
