import 'package:deriv_chart/deriv_chart.dart';
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
            'No results for \"$text\"',
            style: theme.textStyle(
              textStyle: theme.title,
              color: theme.base03Color,
            ),
          ),
          SizedBox(height: theme.margin08),
          Text(
            'Try checking your spelling or use a different term',
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
