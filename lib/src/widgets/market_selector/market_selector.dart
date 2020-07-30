import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/widgets/market_selector/assets_search_bar.dart';
import 'package:deriv_chart/src/widgets/market_selector/models.dart';
import 'package:flutter/material.dart';

/// Clicked on [Asset] in market selector callback.
///
/// [favoriteClicked] is true when user has clicked on favorite icon of the item.
typedef OnAssetClicked = Function(Asset asset, bool favoriteClicked);

/// The animation duration which will take to scroll to selected item in MarketSelector
const scrollToSelectedDuration = Duration(milliseconds: 600);

class MarketSelector extends StatefulWidget {
  const MarketSelector({
    Key key,
    this.onAssetClicked,
    this.markets,
    this.selectedItem,
  }) : super(key: key);

  /// Will be called when a symbol item [Asset] is clicked.
  final OnAssetClicked onAssetClicked;

  final List<Market> markets;

  final Asset selectedItem;

  @override
  _MarketSelectorState createState() => _MarketSelectorState();
}

class _MarketSelectorState extends State<MarketSelector>
    with SingleTickerProviderStateMixin {
  List<Market> _markets;

  /// List of markets after applying the [_filterText].
  List<Market> _marketsToDisplay;

  String _filterText = "";

  /// Is used to scroll to the selected symbol(Asset).
  GlobalObjectKey _selectedItemKey;

  AnimationController _animationController;

  GlobalKey _sheetKey = GlobalKey();

  Size _sheetSize;

  bool didPopped = false;

  @override
  void initState() {
    super.initState();

    _markets = widget.markets;

    _animationController = AnimationController.unbounded(vsync: this, value: 0)
      ..addStatusListener((status) {
        print(status);
        if (status == AnimationStatus.completed &&
            _animationController.value > 0.9) {
          Navigator.of(context).pop();
        }
      });

    _selectedItemKey = GlobalObjectKey(widget.selectedItem.name);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _sheetSize = _initSizes();
      Scrollable.ensureVisible(
        _selectedItemKey.currentContext,
        duration: scrollToSelectedDuration,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();

    super.dispose();
  }

  Size _initSizes() {
    final RenderBox chartBox = _sheetKey.currentContext.findRenderObject();
    return chartBox.size;
  }

  @override
  Widget build(BuildContext context) {
    _marketsToDisplay = _filterText.isEmpty
        ? _markets
        : _markets
            .where((market) =>
                market.containsAssetWithText(_filterText.toLowerCase()))
            .toList();

    return AnimatedBuilder(
      key: _sheetKey,
      animation: _animationController,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(0, _animationController.value),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Material(
          elevation: 8, // TODO(Ramin): Use Chart's theme when its ready
          color: Color(0xFF151717),
          child: Column(
            children: <Widget>[
              _buildTopHandle(),
              AssetsSearchBar(
                onSearchTextChanged: (String text) =>
                    setState(() => _filterText = text),
              ),
              _buildMarketsList(),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildTopHandle() => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              // TODO(Ramin): Use Chart's theme when its ready
              color: const Color(0xFF3E3E3E),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );

  Widget _buildMarketsList() => _marketsToDisplay == null
      ? Container()
      : Expanded(
          child: NotificationListener(
            onNotification: _handleScrollNotification,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ..._marketsToDisplay.map((Market market) => MarketItem(
                        selectedItemKey: _selectedItemKey,
                        filterText: _filterText.toLowerCase(),
                        market: market,
                        onAssetClicked: (asset, isFavoriteClicked) {
                          widget.onAssetClicked?.call(
                            asset,
                            isFavoriteClicked,
                          );
                          if (isFavoriteClicked) {
                            setState(() {
                              asset.toggleFavorite();
                            });
                          }
                        },
                      ))
                ],
              ),
            ),
          ),
        );

  bool _handleScrollNotification(Notification notification) {
    if (_sheetSize != null && notification is OverscrollNotification) {
      final deltaPercent = notification.overscroll / _sheetSize.height;

      if (deltaPercent < 0) {
        _animationController.value -= deltaPercent;
      }
    }

    if (!_animationController.isAnimating &&
        notification is ScrollEndNotification) {
      if (_animationController.value > 0.5) {
        _animationController.animateTo(1,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      } else {
        _animationController.animateTo(0,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    }

    return true;
  }
}
