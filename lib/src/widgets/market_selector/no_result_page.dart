import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Page to show when the api call couldn't get any result.
class NoResultPage extends StatelessWidget {
  /// Creates a page to show when the api call couldn't get any result.
  const NoResultPage({Key? key, this.text = ''}) : super(key: key);

  /// The text to show when the api call couldn't get any result.
  final String text;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);
    return Ink(
      color: theme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search, size: 96, color: theme.base05Color),
            SizedBox(height: theme.margin16Chart),
            Flexible(
              child: Text(
                ChartLocalization.of(context).informNoResult(text),
                textAlign: TextAlign.center,
                style: theme.textStyle(
                  textStyle: theme.title,
                  color: theme.base03Color,
                ),
              ),
            ),
            SizedBox(height: theme.margin08Chart),
            Text(
              ChartLocalization.of(context).warnCheckAssetSearchingText,
              style: theme.textStyle(
                textStyle: theme.body1,
                color: theme.base04Color,
              ),
            ),
            SizedBox(height: theme.margin08Chart),
          ],
        ),
      ),
    );
  }
}
