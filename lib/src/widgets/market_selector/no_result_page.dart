import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoResultPage extends StatelessWidget {
  const NoResultPage({Key key, this.text = ''}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ChartTheme>(context);
    return Container(
      constraints: BoxConstraints.expand(),
      padding: const EdgeInsets.only(top: 94),
      color: theme.base08Color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search, size: 96, color: theme.base05Color),
          SizedBox(height: theme.margin16),
          Text(
            ChartLocalization.of(context).inform_no_result(text),
            style: theme.textStyle(
              textStyle: theme.title,
              color: theme.base03Color,
            ),
          ),
          SizedBox(height: theme.margin08),
          Text(
            ChartLocalization.of(context).warn_check_asset_searching_text,
            style: theme.textStyle(
              textStyle: theme.body1,
              color: theme.base04Color,
            ),
          ),
        ],
      ),
    );
  }
}
