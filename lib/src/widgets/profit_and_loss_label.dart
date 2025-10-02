import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/quill_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO(behnam): remove this widget and use the custom painter implementation instead.
/// {@template profit_and_loss_label}
/// A pill-style label that displays profit or loss with an icon and text.
///
/// This widget is used to display the profit or loss of a contract on the chart.
/// It is displayed as a pill-shaped label with rounded corners containing an icon and the profit/loss
/// amount.
/// {@endtemplate}
class ProfitAndLossLabel extends StatelessWidget {
  /// {@macro profit_and_loss_label}
  const ProfitAndLossLabel({
    required this.text,
    required this.isProfit,
    super.key,
  });

  /// Text to display inside the label (e.g. "+9.55 USD").
  final String text;

  /// Whether the label represents profit (true) or loss (false).
  /// Controls the color scheme of the label i.e. green for profit and red for loss.
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();

    final Color borderColor = isProfit
        ? theme.closedMarkerBorderColorGreen
        : theme.closedMarkerBorderColorRed;

    final Color backgroundColor = isProfit
        ? theme.closedMarkerSurfaceColorGreen
        : theme.closedMarkerSurfaceColorRed;

    final Color textIconColor = isProfit
        ? theme.closedMarkerTextIconColorGreen
        : theme.closedMarkerTextIconColorRed;

    return Opacity(
      opacity: 0.88,
      child: Container(
        height: 32,
        padding: const EdgeInsets.only(right: 16, left: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(QuillIcons.flag_checkered, size: 24, color: textIconColor),
            const SizedBox(width: 4),
            Text(
              text,
              style: theme.textStyle(
                textStyle: theme.profitAndLossLabelTextStyle,
                color: textIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
