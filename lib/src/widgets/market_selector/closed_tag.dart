import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'market_selector.dart';
import 'models.dart';

/// A tag indicating the [Asset] in [MarketSelector] is closed.
class ClosedTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: LegacyLightThemeColors.accentRed, width: 0.8),
      ),
      child: Text(
        'CLOSED',
        style: theme.textStyle(
          textStyle: theme.caption2,
          color: LegacyLightThemeColors.accentRed,
        ),
      ),
    );
  }
}
