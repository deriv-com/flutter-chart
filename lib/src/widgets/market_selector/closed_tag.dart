import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'market_selector.dart';
import 'models.dart';

/// A tag indicating the [Asset] in [MarketSelector] is closed
class ClosedTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: theme.brandCoralColor, width: 0.5),
      ),
      child: Text(
        'Closed',
        style: theme.textStyle(
          textStyle: theme.caption2,
          color: theme.base03Color,
        ),
      ),
    );
  }
}