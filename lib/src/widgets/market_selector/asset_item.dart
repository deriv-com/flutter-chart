import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/highlighted_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'closed_tag.dart';
import 'market_selector.dart';
import 'models.dart';

/// A widget to show an asset (active symbol) item in the market selector.
class AssetItem extends StatelessWidget {
  const AssetItem({
    @required this.asset,
    Key key,
    this.filterText = '',
    this.onAssetClicked,
    this.iconFadeInDuration = const Duration(milliseconds: 50),
  }) : super(key: key);

  final Asset asset;
  final OnAssetClicked onAssetClicked;
  final String filterText;
  final Duration iconFadeInDuration;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = Provider.of<ChartTheme>(context);
    return ListTile(
      contentPadding: EdgeInsets.only(left: theme.margin12),
      leading: _buildAssetIcon(),
      title: _buildAssetTitle(theme),
      onTap: () => onAssetClicked?.call(asset, false),
      trailing: _buildFavouriteIcon(theme),
    );
  }

  Widget _buildAssetTitle(ChartTheme theme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: <Widget>[
      Expanded(
        child: HighLightedText(
          '${asset.displayName}',
          highlightText: filterText,
          style: theme.textStyle(
            textStyle: theme.body1,
            color: theme.base03Color,
          ),
        ),
      ),
      if (!asset.isOpen) ClosedTag(),
    ],
  );

  IconButton _buildFavouriteIcon(ChartTheme theme) => IconButton(
    key: ValueKey<String>('${asset.name}-fav-icon'),
    icon: Icon(
      asset.isFavourite ? Icons.star : Icons.star_border,
      color:
      asset.isFavourite ? theme.accentYellowColor : theme.base04Color,
      size: 20,
    ),
    onPressed: () => onAssetClicked?.call(asset, true),
  );

  Widget _buildAssetIcon() => FadeInImage(
        width: 24,
        height: 24,
        placeholder: const AssetImage(
          'assets/icons/icon_placeholder.png',
          package: 'deriv_chart',
        ),
        image: AssetImage(
          'assets/icons/${asset.name}.png',
          package: 'deriv_chart',
        ),
        fadeInDuration: iconFadeInDuration,
        fadeOutDuration: iconFadeInDuration,
      );
}
